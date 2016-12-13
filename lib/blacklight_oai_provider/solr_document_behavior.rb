# Meant to be applied on top of SolrDocument to implement
# methods required by the ruby-oai provider
module BlacklightOaiProvider
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    class_methods do
      def timestamp_field
        'timestamp'
      end
    end

    def timestamp
      Time.parse fetch(self.class.timestamp_field, Time.at(0).to_s)
    end

    def to_oai_dc
      export_as('oai_dc_xml')
    end
  end
end
