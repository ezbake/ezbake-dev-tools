#!/usr/bin/ruby
if !Object.const_defined?('JRUBY_VERSION') || !JRUBY_VERSION.start_with?('1.7')
    puts 'This script only runs under JRuby 1.7.x or higher!'
    exit
end
require 'optparse'
require 'json'

options = {
    :version => nil,
    :target => :local,
    :appname => 'testapp',
    :initialize_jars => false,
    :code => nil,
    :service => nil,
    :script => nil,
    :jarfile => nil
}

parser = OptionParser.new do |opt|
    opt.banner = 'Usage: jruby shell.rb [options] <artifact>'
    opt.on('-v', '--version VERSION', 'The version of the service to use (defaults to latest)') {|v| options[:version] = v }
    opt.on('-a', '--appname NAME', 'Application name to override the default (testapp)') {|a| options[:appname] = a }
    opt.on('-e', '--eval CODE', 'Evaluate a code string and return the result') {|c| options[:code] = c}
    opt.on('-s', '--script SCRIPT', 'Run a script') {|s| options[:script] = s }
    opt.on('-i', '--init', 'Run the maven updating process and put the jars in the jars folder.') { options[:initialize_jars] = true }
    opt.on('-j', '--jar JARFILE', 'Import the given jarfile and assume it is packaged with all the dependencies to run the service') {|j|
        options[:jarfile] = j
    }
    opt.on('-t', '--target TARGET', 'Where to attempt to start the service (defaults to local). "local" will start the service using the local jar and will assume the backend is set up locally.  "discover:serviceName" will attempt to use ezDiscovery to find the service using the given service name. ') do |t|
            options[:target] = if t.start_with?('discover:')
                options[:service] = t.split(':', 2).last
                :discover
            elsif t == 'local'
                :local
            else
                raise StandardError, "Argument #{t} for target parameter is not local or discover:serviceName!"
            end
    end

    opt.on('-h', '--help', 'Show command help.') { puts opt; exit }
end

parser.parse!
artifact_path = ARGV.shift
abort "No artifact path was passed (expected at least groupId:artifactId)\n#{parser}" if artifact_path.nil?
abort "You cannot eval code and run a script!" if options[:script] && options[:code]
show_output = !(options[:script] || options[:code])

# Load all the libs and the helpers
module Helpers; end
def file_relative_path *paths
    paths.unshift File.dirname(__FILE__)
    File.join(*paths)
end
Dir[file_relative_path('{lib,shell_helpers}', '**', '*.rb')].each {|lib| require lib }

$CLASSPATH << File.expand_path('.')
artifact_id = EzBakeDependencies.parse_artifact(artifact_path)[:artifact]
@artifact_module = Helpers.constants.reduce(nil) do |memo, helper|
    constant = Helpers.const_get(helper)
    constant::ARTIFACT_NAME == artifact_id ? constant : memo
end

abort "Could not find a helper module for artifact '#{artifact_id}'" unless @artifact_module

# Generates jar dependencies if not available
EzBakeDependencies.generate file_relative_path('pom.xml'), artifact_path, options[:version] if options[:initialize_jars]
EzBakeDependencies.require_all

# Import commonly used objects
java_import 'ezbake.base.thrift.Visibility'
java_import 'ezbake.base.thrift.Authorizations'
java_import 'ezbake.base.thrift.AdvancedMarkings'
java_import 'ezbake.base.thrift.PlatformObjectVisibilities'
java_import 'ezbake.base.thrift.ValidityCaveats'
java_import 'ezbake.base.thrift.EzSecurityPrincipal'
java_import 'ezbake.base.thrift.EzSecurityToken'
java_import 'java.nio.ByteBuffer'

# Import the java classes if the artifact module defines an import method
@artifact_module.import if @artifact_module.respond_to?(:import)

@ezconfig = EzConfig.new

# Load the dataset client or handler from the appropriate place
@artifact_obj = if options[:target] == :local
    handler = Java::JavaClass.for_name(@artifact_module::HANDLER_CLASS).ruby_class.new
    handler.configuration_properties = @ezconfig.config
    begin
        init = handler.java_class.declared_method :init
        init.accessible = true
        init.invoke handler
    rescue => e
        puts "There was an error initalizing the server! I would suspect your ezConfig isn't specified correctly."
        puts "  EZCONFIGURATION_DIR = #{ENV['EZCONFIGURATION_DIR']}"
        puts "  EzConfig Properties = \n#{'*' * 70}\n#{@ezconfig}"
        if e.respond_to?(:print_stack_trace)
            e.print_stack_trace
            abort
        else
            abort e.to_s
        end
    end
    handler
elsif options[:target] == :discover
    puts "Attempting to connect to remote thrift service using EzDiscovery path: ezDiscovery/#{options[:appname]}/#{options[:service]}"
    server = ThriftServer.new options[:appname], options[:service], @artifact_module::SERVICE_CLASS, @ezconfig
    server.get_client
end

puts "Created client for service #{artifact_id} using #{options[:target]} target." if show_output

# Wrap the handler so we can call methods without a prefix
class Object
    def method_missing name, *args, &block
        # allow the module to replace methods
        if @artifact_module.respond_to?(name)
            @artifact_module.send name, *([self] + args), &block
        elsif @artifact_obj.respond_to?(name)
            @artifact_obj.send name, *args, &block
        end
    end
    
    def to_hex
        case self
        when ByteBuffer then String.from_java_bytes(self.array).unpack('H*').first
        when Java::byte[0].new.class then String.from_java_bytes(self).unpack('H*').first
        when String then self.unpack('H*').first
        else 
            raise StandardError, "Unsupported type used in to_hex; only supports byte arrays, strings, and ByteBuffers!"
        end
    end
end

# Define some helper methods
def fake_token auths = %w(TS S U)
    token = Java::ezbake.data.test.TestUtils.createTestToken *auths
    token.validity.setIssuedTo @ezconfig.app.getSecurityID
    token.validity.setIssuedFor(options[:service] || 'mockTargetSecurityId')
    token
end

def openshift_token
=begin
	tokenrequest = Java::ezbake.base.thrift.TokenRequest.new
	tokenrequest.setSecurityId @ezconfig.app.getSecurityID
	tokenrequest.setTimeStamp Time.now.getutc
	tokentype = Java::ezbake.base.thrift.TokenType.APP
	tokenrequest.setType tokentype
=end
    tokenprovider = Java::ezbake.security.client.EzbakeSecurityClient.new(@ezconfig.properties)
    token = tokenprovider.fetchAppToken()
    token
end

def fake_binary_token auths = %w(TS S U)
    VisibilityHelper.to_binary fake_token(auths)
end

# NOT REAL CLASSIFICATIONS!
def fake_vis vis = 'S&USA'
    VisibilityHelper.from_string vis
end 

def fake_binary_vis vis = 'S&USA'
    VisibilityHelper.to_binary fake_vis(vis)
end

def write filename, stuff
    if stuff.respond_to(:to_a) && stuff.to_a.size == 1
        File.write filename, stuff.to_a.first.to_s
    else
        File.write filename, stuff.to_s
    end
end

def set_of *args
    set = Java::java.util.HashSet.new()
    args.each {|x| set.add x }
    set
end

def list_of *args
    Java::java.util.Arrays.as_list *args
end

# Generates a simple listing of the methods available optionally filtered by a pattern
def help options = { :pattern => /.*/, :target => nil}
    puts "Global helper methods (available on all services): "
    puts JavaHelpers.format_help_line 'boolean', 'allow_colors', 'true|false', "Turn coloring on/off"
    puts JavaHelpers.format_help_line 'EzSecurityToken', 'fake_token', '[auths=TS,S,U]', 'Return a fake security token.'
    puts JavaHelpers.format_help_line 'Visibility', 'fake_vis', 'String - visibility', 'Return a fake Visibility constructed from the given string.'
    puts JavaHelpers.format_help_line 'void', 'write', 'Filename, Stuff to write', 'Write content to a file.'
    puts JavaHelpers.format_help_line 'Set', 'set_of', 'Comma-separated items', 'Get a Java Set of items.'
    puts JavaHelpers.format_help_line 'List', 'list_of', 'Comma-separated items', 'Get a Java List of items.'
    puts "\n"

    options[:target] = @artifact_obj.java_class if options[:target].nil?
    actual_methods = JavaHelpers.method_help options[:target], options[:pattern]
    if actual_methods.any?
        puts "Available methods on #{options[:target]} are:\n#{actual_methods.join("\n")}"
    else
        puts "No service methods found that match /#{pattern}/!"
    end
    if @artifact_module.respond_to?(:method_help)
        puts "\nCLI Helpers: "
        puts @artifact_module.method_help.join("\n")
    end
end

def allow_colors allow = nil
    String.allow_colors allow
end

def quit
    exit
end

context = binding
context.eval '_ = nil'
puts "Service connected.  Type 'help' to list the callable methods."
puts "ANSI Colors are currently set to #{String.allow_colors ? 'on' : 'off'}. Use 'allow_colors' to toggle colors." if show_output

if show_output
    loop do
        print "> "
        input = gets.chomp!
        begin
            unless input.strip.empty?
                context.eval "_ = (#{input})"
                puts " -> #{context.eval('_.to_s')}"
            end
        rescue SyntaxError => e
            puts " -> Syntax Error! #{e}".red
        rescue SystemExit
            break
        rescue => e
            puts " -> Exception #{e.inspect}".red
            e.print_stack_trace if e.respond_to?(:print_stack_trace)
        end
    end
else
    eval_code = options[:code] ? options[:code] : File.read(options[:script])
    result = context.eval(eval_code)
    puts "RESULTS:"
    if result.is_a?(Java::org.apache.thrift.TBase)
        begin
            serializer = Java::org.apache.thrift.TSerializer.new Java::org.apache.thrift.protocol.TSimpleJSONProtocol::Factory
            puts serializer.toString(result)
        rescue
            puts result.to_s
        end
    else
        puts result.to_s
    end
end