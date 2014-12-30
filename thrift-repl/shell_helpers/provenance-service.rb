module Helpers
    #module EzProvenance 
    #module ProvenanceService
    module EzProvenanceService #service name in thrift
        #ARTIFACT_NAME = 'ezprovenanceservice' #service name in thrift
        ARTIFACT_NAME = 'provenance-service' #artifact name in artifactory
        HANDLER_CLASS = 'ezbake.services.provenance.thrift.ProvenanceServiceImpl'
        SERVICE_CLASS = 'ezbake.services.provenance.thrift.ProvenanceService'

        def self.import
            Object.class_eval do
            end
        end
    end
end
