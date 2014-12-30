module Helpers
    module ImageIndexerService
        ARTIFACT_NAME = 'image-indexer-service'
        HANDLER_CLASS = 'ezbake.services.indexing.image.ImageIndexerServiceHandler'
        SERVICE_CLASS = 'ezbake.services.indexing.image.thrift.ImageIndexerService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
