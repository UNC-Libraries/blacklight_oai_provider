require 'rails_helper'

RSpec.describe BlacklightOaiProvider::SolrDocumentProvider do
  subject { described_class.new(controller, controller.oai_config) }
  let(:controller) { CatalogController.new }

  describe "wrapper class configuration" do
    before do
      CatalogController.configure_blacklight do |config|
        config.oai = {
          provider: {
            repository_name: 'Test',
            repository_url: 'http://example.com',
            wrapper_class: '::MyWrapper'
          }
        }
      end
    end

    it 'uses the specified wrapper class' do
      expect(subject.class.model).to be_a ::MyWrapper
    end
  end
end
