module Helpers
    module EzPurge
        ARTIFACT_NAME = 'ezcentralpurgeservice'
        HANDLER_CLASS = 'ezbake.services.centralPurge.thrift.EzCentralPurgeServiceHandler'
        SERVICE_CLASS = 'ezbake.services.centralPurge.thrift.EzCentralPurgeService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
