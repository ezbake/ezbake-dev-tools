module Helpers
    module ClassificationService
        ARTIFACT_NAME = 'classification-normalizer-service'
        HANDLER_CLASS = 'ezbake.services.classification.ClassificationServiceHandler'
        SERVICE_CLASS = 'ezbake.services.classification.thrift.ClassificationService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
