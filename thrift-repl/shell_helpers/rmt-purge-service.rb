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
    
    module EzBakeBasePurgeService
        ARTIFACT_NAME = 'rmt-purge-service'
        HANDLER_CLASS = 'rmt.purge.handler.RMTPurgeServiceHandler'
        SERVICE_CLASS = 'ezbake.base.thrift.EzBakeBasePurgeService'

        def self.import
            Object.class_eval do
            end
        end
        
=begin        
        def self.beginPurge obj, zoocallback, purgeId, purgeItems, token
            result = obj.beginPurge zoocallback, purgeId, purgeItems, token
            
            file = File.new("./listBlobs/".concat(outputfile), File::CREAT|File::TRUNC|File::RDWR, 0644)
            
            result.each do |blob|
            	puts "Writing ByteBuffer into the File"
            	file.write("Bucket: ")
            	file.write(blob.getBucket())
            	file.write("\n")
            	file.write("Key: ")
            	file.write(blob.getKey())
            	file.write("\n")
            	file.write("Blob: ")
            	file.write(blob.getBlob())
            	file.write("\n")
            	file.write("\n")
            end
            
            file.close
        end
=end

        
    end
end