module Helpers
    module TemporalNormalizerService
        ARTIFACT_NAME = 'temporal-normalizer-service'
        HANDLER_CLASS = 'ezbake.services..normalizer.temporal.TemporalNormalizerServiceHandler'
        SERVICE_CLASS = 'ezbake.services.normalizer.temporal.thrift.TemporalNormalizerService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
