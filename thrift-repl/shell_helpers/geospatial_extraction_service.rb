module Helpers
    module GeospatialExtractorService
        ARTIFACT_NAME = 'geospatial-extraction-service'
        HANDLER_CLASS = 'ezbake.services.geospatial.GeospatialExtractionServiceHandler'
        SERVICE_CLASS = 'ezbake.services.geospatial.thrift.GeospatialExtractorService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
