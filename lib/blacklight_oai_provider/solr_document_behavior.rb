# Meant to be applied on top of SolrDocument to implement
# methods required by the ruby-oai provider
module BlacklightOaiProvider
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    def timestamp
      Time.parse(fetch('timestamp', Time.at(0).utc.to_s)).utc
    end

    def to_oai_dc
      export_as('oai_dc_xml')
    end
  end
end
