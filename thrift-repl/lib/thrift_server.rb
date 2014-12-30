
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