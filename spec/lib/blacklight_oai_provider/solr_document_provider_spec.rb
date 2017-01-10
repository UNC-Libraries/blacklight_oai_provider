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
end
