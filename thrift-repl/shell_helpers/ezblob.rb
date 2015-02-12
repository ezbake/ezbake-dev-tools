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
    module EzBlob
        ARTIFACT_NAME = 'ezblob'
        HANDLER_CLASS = 'ezbake.data.blob.EzBlobHandler'
        SERVICE_CLASS = 'ezbake.data.base.blob.thrift.EzBlob'

        def self.import
            Object.class_eval do
                java_import 'ezbake.data.base.blob.thrift.Blob'
                java_import 'ezbake.data.base.blob.thrift.BlobException'
                java_import 'ezbake.data.base.blob.thrift.EzBlob'
            end
        end
        
        def self.method_help
            [
                JavaHelpers.format_help_line('Blob', 'blob', 'bucket, key, file, visibility', 
                    'Create a Blob object with the given bucket and key, using the given filename for binary, and with a visibility using the standard visibility formatting.'
                ), 
            	JavaHelpers.format_help_line('Set<ByteBuffer>', 'getBlobsHelper', 'bucket,key,security token,output file name', 
                	'Output Stored in output file name given and stored in ./getBlobs folder'
                ),
    			JavaHelpers.format_help_line('List<Blob>', 'listBlobsHelper', 'bucket,security token,output file name', 
    				'Output Stored in output file name given and stored in ./listBlobs folder'
    			)
            ]
        end
        
        def self.blob obj, bucket, key, file, visibility
            vis = if visibility.is_a?(Visibility)
                visibility
            else
                VisibilityHelper.from_string(visibility.to_s)
            end
            Blob.new bucket, key, ByteBuffer.wrap(File.read(file).to_java_bytes), vis
        end
        
        def self.getBlobsHelper obj, bucket, key, token, outputfile
            result = obj.getBlobs bucket, key, token
            
            result_array = result.to_a()
            puts "Array Size : #{result_array.size()}"
            
            file = File.new("./getBlobs/".concat(outputfile), File::CREAT|File::TRUNC|File::RDWR, 0644)
            
            result_array.each do |element|
            	puts "Writing ByteBuffer into the File"
            	file.write(element.array())
            end
            
            file.close
        end
        
        def self.listBlobsHelper obj, bucket, token, outputfile
            result = obj.listBlobs bucket, token
            
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
        
    end
end
