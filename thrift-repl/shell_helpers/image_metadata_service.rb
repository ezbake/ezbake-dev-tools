#   Copyright (C) 2013-2014 Computer Sciences Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

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

