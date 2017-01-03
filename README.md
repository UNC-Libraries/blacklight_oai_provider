# BlacklightOaiProvider

OAI-PMH service endpoint for Blacklight applications

## Description

The BlacklightOaiProvider plugin provides an [Open Archives Initiative Protocolo for Metadata Harvesting](http://www.openarchives.org/pmh/) (OAI-PMH) data provider endpoint, using the ruby-oai gem, that let serice providers harvest that metadata.

## Requirements

A Rails 4 application using Blacklight 6.

## Installation

Add

    gem 'blacklight_oai_provider', git: 'https://github.com/osulibraries/blacklight_oai_provider.git', branch: 'master'

to your Gemfile and run `bundle install`.

Then run `bundle exec rails generate blacklight_oai_provider` to install the appropriate extensions into your `CatalogController`, `SolrDocument`, and routes.

After runniing the generator, `config/routes.rb` should contain a definition for the `:oai_provider` concern. You may need to add this concern to the route definition for the Blacklight catalog controller. For example:

    resource :catalog, only: [:index], path: '/catalog', controller: 'catalog' do
      concerns :oai_provider
    end 

If you want to do customize the installation, instead you may:

  * extend your Solr Document model:
    
    include BlacklightOaiProvider::SolrDocumentBehavior
    use_extension Blacklight::Document::DublinCore

  * extend your Controller:

    include BlacklightOaiProvider::CatalogControllerBehavior

  * add the concern your `config/routes.rb` and apply it to your Blacklight catalog routes as described above:

    concern :oai_provider, BlacklightOaiProvider::Routes::Provider.new

### Timestamps

OAI-PMH requires a timestamp field for all records, so your Solr index should include an appropriate field. By default, the name of this field is simply "timestamp". The OAI SolrDocument behavior adds methods to the`SolrDocument` class to fetch timestamp data.

If the Solr field holding your timestamp is not called "timestamp", you should override the `timestamp_field` class method to return the correct field name, ie:

    class SolrDocument
      def self.timestamp_field
        'date_modified'
      end
    end

The `timestamp` method is expected to return a Ruby `Time` object. You can override this method if necessary to perform extra processing:

    class SolrDocument
      def timestamp
        Time.parse message_my_data(fetch(self.class.timestamp_field))
      end
    end

You can also explicitly configure the timestamp Solr field and SolrDocument method:

    config.oai = {
      document: {
        timestamp_field: 'timestamp_dtsi',
        timestamp_method: 'date_created'
      }
    }

### Field mapping

In order to provide metadata to the OAI-PMH emdpoint, your `SolrDocument` will need to map DC terms to Solr fields. See `Blacklight::Document::DublinCore` for more information.

    class SolrDocument
      # ...
      field_semantics.merge!(
        creator:     'creator',
        date:        'date_created',
        description: 'description',
        rights:      'rights',
        title:       'title',
        type:        'resource_type')
      # ...
    end

## Configuration

While the plugin provides some sensible (albeit generic) defaults out of the box, you probably will want to customize the OAI provider configuration.

### For Blacklight 6.x.x

in `app/controllers/catalog_controller.rb`

    configure_blacklight do |config|
      config.oai = {
        provider: {
          repository_name: 'Test',
          repository_url: 'http://localhost',
          record_prefix: '',
          admin_email: 'root@localhost'
        },
        document: {
          limit: 25
        }
      }
    end

The "provider" configuration is documented as part of the ruby-oai gem at [http://oai.rubyforge.org/](http://oai.rubyforge.org/)

## Tests

There are currently a few basic tests, but contributions are welcome!

To run the test suite, you'll need to install all development dependencies using Bundler:

    $ bundle install

Then, run the tests using RSpec:

    $ bundle exec rspec

The specs use [VCR](https://github.com/vcr/vcr) to play back HTTP responses from a Solr index. If you need to work directly with a live Solr instance, you will need to run `solr_wrapper` from the root of the dummy Rails application.

    $ cd spec/dummy
    $ bundle exec solr_wrapper

Then, in another terminal, seed the test data into Solr:

    $ cd spec/dummy
    $ bundle exec rake spec:solr:index

To view the dummy application in your browser, chnage to the application root and run rails from the bin script:

    $ cd spec/dummy
    $ bin/rails server

You can test OAI-PMH conformance against [http://www.openarchives.org/data/registerasprovider.html#Protocol_Conformance_Testing](http://www.openarchives.org/data/registerasprovider.html#Protocol_Conformance_Testing) or browse the data at [http://re.cs.uct.ac.za/](http://re.cs.uct.ac.za/) 
