module BlacklightOaiProvider
  class SolrDocumentProvider < ::OAI::Provider::Base
    attr_accessor :options

    def initialize(controller, options = {})
      options[:provider] ||= {}
      options[:document] ||= {}

      options[:provider][:repository_name] ||= controller.view_context.send(:application_name)
      options[:provider][:repository_url] ||= controller.view_context.send(:oai_provider_catalog_url)

      self.class.model = SolrDocumentWrapper.new(controller, options[:document])

      options[:provider].each do |k, v|
        self.class.send k, v
      end
    end

    def process_request(params = {})
      return OAI::Provider::Response::Error.new(self.class, OAI::ArgumentException.new).to_xml unless valid_dates?(params)
      super
    end

    def list_sets(options = {})
      Response::ListSets.new(self.class, options).to_xml
    end

    private

    def valid_dates?(params)
      invalid = false
      invalid = true if params[:from] && invalid_date?(params[:from])
      invalid = true if params[:until] && invalid_date?(params[:until])
      invalid = true if params[:from] && params[:until] && params[:from].length != params[:until].length
      invalid
    end

    def invalid_date?(str)
      !Time.parse(str).utc.iso8601.include?(str)
    end
  end
end
