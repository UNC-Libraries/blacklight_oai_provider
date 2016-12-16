module BlacklightOaiProvider
  class SolrDocumentProvider < ::OAI::Provider::Base
    attr_accessor :options

    def initialize(controller, options = {})
      options[:provider] ||= {}
      options[:document] ||= {}

      self.class.model = SolrDocumentWrapper.new(controller, options[:document])

      options[:provider][:repository_name] ||= controller.view_context.send(:application_name)
      options[:provider][:repository_url] ||= controller.view_context.send(:oai_provider_catalog_url)

      options[:provider].each do |k, v|
        self.class.send k, v
      end
    end
  end
end
