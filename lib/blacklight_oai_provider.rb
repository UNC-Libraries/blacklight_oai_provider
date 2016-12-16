# BlacklightOaiProvider

module BlacklightOaiProvider
  autoload :CatalogControllerBehavior, 'blacklight_oai_provider/catalog_controller_behavior'
  autoload :SolrDocumentBehavior, 'blacklight_oai_provider/solr_document_behavior'
  autoload :SolrDocumentProvider, 'blacklight_oai_provider/solr_document_provider'
  autoload :SolrDocumentWrapper, 'blacklight_oai_provider/solr_document_wrapper'
  autoload :Routes, 'blacklight_oai_provider/routes'

  require 'oai'
  require 'blacklight_oai_provider/version'
  require 'blacklight_oai_provider/engine'

  # Add element to array only if it's not already there
  def self.safe_arr_add(array, element)
    array << element unless array.include?(element)
  end
end
