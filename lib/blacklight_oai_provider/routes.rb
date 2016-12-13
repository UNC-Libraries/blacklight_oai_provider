module BlacklightOaiProvider
  module Routes
    class Provider
      def initialize(defaults = {})
        @defaults = defaults
      end

      def call(mapper, options = {})
        options = @defaults.merge(options)
        mapper.get 'oai', action: 'oai', as: 'oai_provider', via: [:get, :post]
      end
    end
  end
end
