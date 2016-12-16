module BlacklightOaiProvider
  module Routes
    class Provider
      def initialize(defaults = {})
        @defaults = defaults
      end

      def call(mapper, _options = {})
        mapper.match 'oai', action: 'oai', as: 'oai_provider', via: [:get, :post]
      end
    end
  end
end
