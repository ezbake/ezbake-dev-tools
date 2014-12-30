module Helpers
    module AvService
        ARTIFACT_NAME = 'av-service'
        HANDLER_CLASS = 'ezbake.services.av.AVServiceHandler'
        SERVICE_CLASS = 'ezbake.services.av.thrift.AVService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
