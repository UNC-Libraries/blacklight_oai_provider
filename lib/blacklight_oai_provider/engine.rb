require 'blacklight'
require 'blacklight_oai_provider'
require 'rails'

module BlacklightOaiProvider
  class Engine < Rails::Engine
    initializer "blacklight_oai_provider.assets.precompile" do |app|
      app.config.assets.precompile += %w(oai2.xsl)
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
