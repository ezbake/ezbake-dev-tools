#   Copyright (C) 2013-2014 Computer Sciences Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

module EzBakeDependencies
    def self.generate pom, artifact, version
        pomfile = if Gem::Specification::find_all_by_name('nokogiri').any?
            transform_pom pom, artifact, version
        else
            puts "WARNING: Nokogiri was not found (you may be using the jruby-complete jar) -- the POM will be used
                  without being transformed."
            pom
        end

        puts 'Running maven to update jars as necessary...'
        if `mvn compile -U -f #{pomfile}` =~ /\[ERROR\]/
            raise StandardError, 'Could not generate service jars!'
        end
    end

    def self.transform_pom pom, artifact, version
        require 'nokogiri'

        pomfile = Nokogiri::XML(File.read(pom.to_s))
        ezbake_version = "RELEASE"
        pomfile.at_css('project>properties').children.each {|n|
            if n.name == 'ezbake.version'
                n.content = version if version
                ezbake_version = n.content
            end
        }
        dependencies = pomfile.at_css('project>dependencies')
        parsed_artifact = parse_artifact artifact.to_s

        raise StandardError, "Could not parse the artifact path #{artifact}" unless parsed_artifact
        raise StandardError, 'No group was specified for the artifact path!' unless parsed_artifact[:group]
        raise StandardError, 'No artifact was specified for the artifact path!' unless parsed_artifact[:artifact]

        node_xml = Nokogiri::XML::Node.new('dependency', pomfile)
        node_xml.inner_html = "
        <groupId>#{parsed_artifact[:group]}</groupId>
        <artifactId>#{parsed_artifact[:artifact]}</artifactId>
        <version>#{version || ezbake_version}</version>"
        node_xml.inner_html += "<type>#{parsed_artifact[:packaging]}</type>" if parsed_artifact[:packaging]
        node_xml.inner_html += "<classifier>#{parsed_artifact[:classifier]}</classifier>" if parsed_artifact[:classifier]
        dependencies << node_xml

        outpom = File.join(File.dirname(__FILE__), '..', 'userpom.xml')
        File.write outpom, pomfile.to_xml
        outpom
    end

    def self.require_all
        has_required = false
        Dir[File.join(File.dirname(__FILE__), '..', 'jars', '*.jar')].each do |jar|
            has_required = true
            require jar
        end
        abort "No jars were found; please run with the --init (-i) to pull down the jars!" unless has_required
    end

    def self.parse_artifact artifact
        artifact.match(/
            (?<group>[\w\d\-\_\.]+):
            (?<artifact>[\w\d\-\_\.]+)
            (:(?<packaging>[\w\d\-\_\.]*)
                (:(?<classifier>[\w\d\-\_\.]*))?)?/x)
    end
end
