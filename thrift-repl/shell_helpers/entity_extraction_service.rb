module Helpers
    module EntityExtractorService
        ARTIFACT_NAME = 'entity-extraction-service'
        HANDLER_CLASS = 'ezbake.services.extractor.entity.EntityExtractorServiceHandler'
        SERVICE_CLASS = 'ezbake.services.extractor.entity.thrift.EntityExtractorService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
