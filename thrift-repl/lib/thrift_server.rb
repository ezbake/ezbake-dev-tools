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


class ThriftServer
    def initialize application_name, service_name, service_class, ezconfig
        @service_class = service_class.to_s
        @application_name = application_name
        @service_name = service_name
        @pool = Java::ezbake.thrift.ThriftClientPool.new(ezconfig.config)
    end

    def get_client &block
        java_client = Java::JavaClass.for_name(@service_class).ruby_class::Client.java_class
        client = @pool.get_client @application_name, @service_name, java_client
        if block_given?
            block.call client
            @pool.return_to_pool(client)
            nil
        else
            client
        end
    end
end