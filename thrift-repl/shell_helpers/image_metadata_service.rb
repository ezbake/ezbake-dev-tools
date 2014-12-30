module Helpers
    module ImageMetadataService
        ARTIFACT_NAME = 'image-metadata-extraction-service'
        HANDLER_CLASS = 'ezbake.services.extractor.imagemetadata.ImageMetadataExtractorServiceHandler'
        SERVICE_CLASS = 'ezbake.services.extractor.imagemetadata.thrift.ImageMetadataExtractorService'

        def self.import
            java_import 'ezbake.services.extractor.imagemetadata.thrift.Image'
            java_import 'ezbake.services.extractor.imagemetadata.thrift.ImageMetadata'
            java_import 'ezbake.services.extractor.imagemetadata.thrift.ImageMetadataExtractorService'
            java_import 'ezbake.services.extractor.imagemetadata.thrift.InvalidImageException'
        end
    end
end

