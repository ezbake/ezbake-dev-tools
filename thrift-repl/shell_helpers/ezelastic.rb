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
    module EzElastic
        ARTIFACT_NAME = 'ezelastic'
        HANDLER_CLASS = 'ezbake.data.elastic.EzElasticHandler'
        SERVICE_CLASS = 'ezbake.data.elastic.thrift.EzElastic'

        def self.import
            Object.class_eval do
                java_import 'ezbake.data.elastic.thrift.Document'
                java_import 'ezbake.base.thrift.Visibility'
                java_import 'ezbake.data.elastic.thrift.SearchResult'
                java_import 'ezbake.data.elastic.thrift.IndexResponse'
                java_import 'ezbake.data.elastic.thrift.SortOrder'
                java_import 'ezbake.data.elastic.thrift.SortMode'
                java_import 'ezbake.data.elastic.thrift.MissingOrder'
                java_import 'ezbake.data.elastic.thrift.MissingSort'
                java_import 'ezbake.data.elastic.thrift.GeoSortValue'
                java_import 'ezbake.data.elastic.thrift.DistanceUnit'
                java_import 'ezbake.data.elastic.thrift.GeoDistanceSort'
                java_import 'ezbake.data.elastic.thrift.FieldSort'
                java_import 'ezbake.data.elastic.thrift.SortCriteria'
                java_import 'ezbake.data.elastic.thrift.HighlightedField'
                java_import 'ezbake.data.elastic.thrift.HighlightRequest'
                java_import 'ezbake.data.elastic.thrift.Query'
                java_import 'ezbake.data.elastic.thrift.FieldsNotFound'
                java_import 'ezbake.data.elastic.thrift.DocumentIndexingException'
                java_import 'ezbake.data.elastic.thrift.MalformedQueryException'
            end
        end
        
        def self.method_help
            [
                JavaHelpers.format_help_line('Document', 'doc', 'id, type, visibility, json', 
                    "Create a document with the given id, type, and visibility.  The json can be in the form of a string
                     or a ruby hash.  For example as a ruby hash: `doc(id, type, vis, a:1, b:2, c:3)`"),
                JavaHelpers.format_help_line('SearchResult', 'q', 'queryString, contents', "Shorthand for query. 
                    Contents can specify the token as `q(string, token: fake_token)` where fake_token is a security token.")    
            ]
        end

        def self.doc obj, id, type, visibility, json
            d = Document.new type.to_s, VisibilityHelper.from_string(visibility.to_s), json.respond_to?(:to_hash) ? json.to_hash.to_json : json.to_s
            d.set_id id
            d
        end

        def self.q obj, queryString, contents = {}
            token = Java::ezbake.data.test.TestUtils.create_test_token 'U'
            query = Query.new queryString

            obj.query query, contents[:token] || token
        end
    end
end
