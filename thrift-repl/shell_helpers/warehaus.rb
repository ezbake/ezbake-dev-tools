module Helpers
    module Warehaus
        ARTIFACT_NAME = 'warehaus'
        HANDLER_CLASS = 'ezbake.warehaus.AccumuloWarehaus'
        SERVICE_CLASS = 'ezbake.warehaus.WarehausService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
