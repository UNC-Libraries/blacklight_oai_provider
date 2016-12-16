require 'rails_helper'

RSpec.feature 'OAI-PMH catalog endpoint' do
  let(:repo_name) { 'My Test Repository' }
  let(:format) { 'oai_dc' }
  let(:limit) { 10 }
  let(:oai_config) { { provider: { repository_name: repo_name }, document: { limit: limit } } }

  before do
    CatalogController.configure_blacklight do |config|
      config.oai = oai_config
    end
  end

  describe 'root page' do
    scenario 'displays an error message about missing verb' do
      visit oai_provider_catalog_path
      expect(page).to have_content('not a legal OAI-PMH verb')
    end
  end

  describe 'Identify verb' do
    scenario 'displays repository information' do
      visit oai_provider_catalog_path(verb: 'Identify')
      expect(page).to have_content(repo_name)
    end
  end

  describe 'ListRecords verb', :vcr do
    scenario 'displays a limited list of records' do
      visit oai_provider_catalog_path(verb: 'ListRecords', metadataPrefix: format)
      expect(page).to have_selector('record', count: limit)
    end

    context 'with a resumption token' do
      let(:oai_config) { { provider: { repository_name: repo_name }, document: { limit: 25 } } }

      scenario 'displays the next page of records' do
        params = { verb: 'ListRecords', resumptionToken: "oai_dc.f(1970-01-01T00:00:00Z).u(2016-12-16T15:40:34Z):25" }
        visit oai_provider_catalog_path(params)
        expect(page).to have_selector('record', count: 5)
      end
    end
  end

  describe 'ListSets verb' do
    scenario 'shows that no sets exist' do
      visit oai_provider_catalog_path(verb: 'ListSets')
      expect(page).to have_content('This repository does not support sets')
    end
  end

  describe 'ListMetadataFormats verb' do
    scenario 'lists the oai_dc format' do
      visit oai_provider_catalog_path(verb: 'ListMetadataFormats')
      expect(page).to have_content(format)
    end
  end

  describe 'ListIdentifiers verb', :vcr do
    let(:expected_ids) { %w(oai:localhost/2005553155 oai:localhost/00313831) }

    scenario 'lists identifiers for works' do
      visit oai_provider_catalog_path(verb: 'ListIdentifiers', metadataPrefix: format)
      expect(page.body).to include(*expected_ids)
    end
  end
end
