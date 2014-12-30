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