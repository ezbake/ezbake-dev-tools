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
    module EzMongo
        ARTIFACT_NAME = 'ezmongo'
        HANDLER_CLASS = 'ezbake.data.mongo.EzMongoHandler'
        SERVICE_CLASS = 'ezbake.data.mongo.thrift.EzMongo'

        def self.import
            Object.class_eval do
                java_import 'ezbake.data.mongo.thrift.EzMongoBaseException'
                java_import 'ezbake.data.mongo.thrift.MongoFindParams'
                java_import 'ezbake.data.mongo.thrift.MongoEzbakeDocument'
                java_import 'ezbake.data.mongo.thrift.MongoUpdateParams'
                java_import 'ezbake.data.mongo.thrift.MongoDistinctParams'
            end
        end
        
        def self.method_help
            [
                JavaHelpers.format_help_line('MongoEzbakeDocument', 'doc', 'visibility, json')
            ]
        end
        
        def self.doc _, vis, json
            MongoEzbakeDocument.new(json.respond_to?(:to_hash) ? json.to_hash.to_json : json.to_s, VisibilityHelper.from_string(vis))
        end
        
    end
end
