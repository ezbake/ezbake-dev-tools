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

class String

    def camelize
        tokens = self.split('_')
        first = tokens.shift
        first + tokens.map {|m| m[0].upcase + m[1..-1]}.join
    end

    # attempt to turn a full package name into just the class name
    #  org.foo.bar.Class<org.foo.bar.Item> => Class<Item>
    def java_class_name
        names = self.split(/[<>]/).map {|type| type.split('.').last }
        names.shift + (names.any? ? "<#{names.join(', ')}>" : '')
    end

    # Colorization helpers
    @@allow_colors = true
    def self.allow_colors allow = nil
        @@allow_colors = allow unless allow.nil?
        @@allow_colors
    end

    def colorize(color_code)
        self.class.allow_colors ? "\e[#{color_code}m#{self}\e[0m" : self
    end

    def red
        colorize(31)
    end

    def green
        colorize(32)
    end

    def yellow
        colorize(33)
    end

    def blue
        colorize(34)
    end

    def pink
        colorize(35)
    end
end
