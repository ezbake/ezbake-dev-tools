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

module JavaHelpers
    # Returns array of help strings for each method
    def self.method_help java_obj, pattern
        java_obj.declared_instance_methods.reject {|m|
            %w(send_ recv_ __j getOutputProtocol getInputProtocol == equals
               input_protocol output_protocol get_input_protocol get_output_protocol).any? {|p| m.name.start_with? p} || \
                m.name !~ (pattern.is_a?(Regexp) ? pattern : Regexp.new(pattern, true) )
        }.map {|m|
            m.to_generic_string.split(/[() ]/).drop(1)
        }.sort_by {|return_type, method, params, etc| method }.map {|return_type, method, params, etc|
            params_list = params.split(',').map(&:java_class_name)
            format_help_line return_type.java_class_name, method.java_class_name, params_list
        }
    end
    
    def self.format_help_line return_type, method_name, params_list, description = ''
        formatted_params = params_list.respond_to?(:map) ? params_list.map {|p| p.green }.join(', ') : params_list.to_s
        formatted_desc = description.empty? ? ';' : " - #{description}"
        "* #{return_type.yellow} #{method_name}(#{ formatted_params })" + formatted_desc
    end
    
end