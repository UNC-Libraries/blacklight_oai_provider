require 'rails_helper'

RSpec.describe BlacklightOaiProvider::SolrDocumentProvider do
  let(:options) { { provider: { repository_url: 'http://example.com' } } }
  let(:provider) { described_class.new(controller, options) }
  let(:controller) { CatalogController.new }

  describe '#process_request' do
    subject { provider.process_request(params) }

    context 'with an invalid from date' do
      let(:params) { { from: 'junk' } }
      it { is_expected.to include('badArgument') }
    end

    context 'with an invalid until date' do
      let(:params) { { until: 'asdasda' } }
      it { is_expected.to include('badArgument') }
    end

    context 'with from and until dates of different granularities' do
      let(:params) { { from: '2011-01-01', until: '2011-02-02T01:00:00' } }
      it { is_expected.to include('badArgument') }
    end
  end

  describe '#initialize' do
    context 'with a callable provider parameter' do
      let(:url) { 'http://example.test' }
      let(:options) { { provider: { repository_url: -> { url } } } }

      it 'uses the return value of the proc' do
        expect(provider.class.url).to eq url
      end
    end
  end
end
