module BlacklightOaiProvider
  module Routes
    class Provider
      def initialize(defaults = {})
        @defaults = defaults
      end

      def call(mapper, options = {})
        defaults = { action: 'oai', as: 'oai_provider', via: [:get, :post] }
        mapper.match 'oai', defaults.merge(options)
      end
    end
  end
end
