require 'FileUtils'

ENV['EZCONFIGURATION_DIR'] = File.expand_path(File.join(File.dirname(__FILE__), '..'))
Java::java.lang.System.set_property 'EZCONFIGURATION_DIR', ENV['EZCONFIGURATION_DIR']

class EzConfig
    attr_reader :config

    def initialize
        self.class.build_properties_file

        java_import 'ezbake.configuration.EzConfiguration'
        java_import 'ezbake.configuration.ClasspathConfigurationLoader'
        java_import 'ezbake.configuration.DirectoryConfigurationLoader'
        java_import 'ezbake.configuration.OpenShiftConfigurationLoader'
        java_import 'ezbake.common.openshift.OpenShiftUtil'

        if OpenShiftUtil.inOpenShiftContainer()
        	puts "  In Open Shift Container  "
        	@config = EzConfiguration.new(OpenShiftConfigurationLoader.new).properties
        else
        	puts "  In Ezcentos Container  "
        	puts "  EZCONFIGURATION_DIR = #{ENV['EZCONFIGURATION_DIR']}"
        	@config = EzConfiguration.new(ClasspathConfigurationLoader.new).properties
        end

    end

    def app
        Java::ezbakehelpers.ezconfigurationhelpers.application.EzBakeApplicationConfigurationHelper.new(@config)
    end

    def zoo
        Java::ezbakehelpers.ezconfigurationhelpers.zookeeper.ZookeeperConfigurationHelper.new(@config)
    end

    def properties
    	@config
    end

    def to_s
        @config.entry_set.reduce('') do |memo, entry|
            "#{memo}\n #{entry.key} = #{entry.value}"
        end
    end

    def self.build_properties_file
        default_file = File.join(ENV['EZCONFIGURATION_DIR'], 'ezbake-config.properties.default')
        new_file = File.join(ENV['EZCONFIGURATION_DIR'], 'ezbake-config.properties')

        FileUtils.copy_file(default_file, new_file) unless File.exists?(new_file)
    end
end
