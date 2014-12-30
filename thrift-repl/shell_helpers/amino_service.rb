module Helpers
    module AminoService
        ARTIFACT_NAME = 'amino-service'
        HANDLER_CLASS = 'ezbake.services.amino.AminoServiceHandler'
        SERVICE_CLASS = 'ezbake.services.amino.thrift.AminoService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
