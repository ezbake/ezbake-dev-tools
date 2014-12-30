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
