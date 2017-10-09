# Blacklight OAI-PMH Provider

[![Build Status][BS img]][Build Status]
[![Coverage Status][CS img]][Coverage Status]

OAI-PMH service endpoint for Blacklight applications.

## Description

The BlacklightOaiProvider plugin provides an [Open Archives Initiative Protocolo for Metadata Harvesting](http://www.openarchives.org/pmh/) (OAI-PMH) data provider endpoint, using the `ruby-oai` gem, that let serice providers harvest that metadata.

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

If you want to customize the installation, instead you may:

  * Extend your Solr Document model:
    
    ```
    include BlacklightOaiProvider::SolrDocumentBehavior
    use_extension Blacklight::Document::DublinCore
    ```

  * Extend your Controller:

    ```
    include BlacklightOaiProvider::CatalogControllerBehavior
    ```

  * Add the concern to `config/routes.rb` and apply it to your Blacklight catalog routes as described above:

    ```
    concern :oai_provider, BlacklightOaiProvider::Routes::Provider.new
    ```

## Configuration

While the plugin provides some sensible (albeit generic) defaults out of the box, you probably will want to customize the OAI provider configuration. All configuration parameters are optional.

In `app/controllers/catalog_controller.rb`

    configure_blacklight do |config|
      config.oai = {
        provider: {
          repository_name: 'My Test Repository',
          repository_url: 'http://localhost',
          record_prefix: 'example.com',
          admin_email: 'root@localhost'
        },
        document: {
          limit: 25
        }
      }
    end

The "provider" configuration is documented as part of the `ruby-oai` gem at [http://oai.rubyforge.org/](http://oai.rubyforge.org/)

### Timestamps

OAI-PMH requires a timestamp field for all records, so your Solr index should include an appropriate field. By default, the name of this field is simply "timestamp". The OAI SolrDocument behavior adds methods to the`SolrDocument` class to fetch timestamp data.

The `timestamp` method is expected to return a Ruby `Time` object. You can override this method if necessary to perform extra processing:

    class SolrDocument
      def timestamp
        Time.parse message_my_data(fetch('timestamp'))
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

### Sets

A basic set model is included that maps Solr fields to OAI sets. First, provide the fields to use as sets in the OAI config:

    config.oai = {
      document: {
        set_fields: 'language'
      }
    }

This will cause the `ListSets` verb to query Solr for unique values of the `language` field and present each value as a set using a spec format of `language:value`. When the `set` parameter is supplied to the `ListRecords` verb, it will append a filter to the Solr query of the form `fq=language:value`.

Finally, your `SolrDocument` model must implement a `sets` method that returns an array of sets for each document. Ex:

    def sets
      fetch('language', []).map { |l| BlacklightOaiProvider::Set.new("language:#{l}") }
    end

You can substitute your own Set model using the `set_class` option. See `lib/blacklight_oai_provider/set` for an example implementation and `spec/dummy/app/models/oai_set.rb` for an example of adding a description method to the standard implementation.

    config.oai = {
      document: {
        set_fields: 'language',
        set_class: '::MySetModel'
      }
    }

## Tests

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

To view the dummy application in your browser, change to the application root and run rails from the bin script:

    $ cd spec/dummy
    $ bin/rails server

You can test OAI-PMH conformance against [http://www.openarchives.org/data/registerasprovider.html#Protocol_Conformance_Testing](http://www.openarchives.org/data/registerasprovider.html#Protocol_Conformance_Testing) or browse the data at [http://re.cs.uct.ac.za/](http://re.cs.uct.ac.za/)


[Build Status]: https://travis-ci.org/osulibraries/blacklight_oai_provider
[Coverage Status]: https://coveralls.io/github/osulibraries/blacklight_oai_provider?branch=master

[BS img]: https://travis-ci.org/osulibraries/blacklight_oai_provider.svg?branch=master
[CS img]: https://coveralls.io/repos/github/osulibraries/blacklight_oai_provider/badge.svg?branch=master
