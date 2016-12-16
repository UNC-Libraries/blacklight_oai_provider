require 'rails_helper'

RSpec.describe BlacklightOaiProvider::SolrDocumentWrapper do
  subject { described_class.new(controller, {}) }
  let(:controller) { CatalogController.new }

  before { allow(controller).to receive(:params).and_return({}) }

  describe "#sets" do
    it 'returns nil to indicate sets are not supported' do
      expect(subject.sets).to be_nil
    end
  end

  describe "#earliest", :vcr do
    it 'returns the earliest timestamp of all the records' do
      expect(subject.earliest).to eq Time.parse('2014-01-22 18:42:53.056000000 +0000')
    end
  end

  describe "#latest", :vcr do
    it 'returns the latest timestamp of all the records' do
      expect(subject.latest).to eq Time.parse('2014-10-10 18:42:53.056000000 +0000')
    end
  end

  describe "#find", :vcr do
    context 'when selector is :all' do
      it 'returns a limited list of all records' do
        expect(subject.find(:all)).to be_a OAI::Provider::PartialResult
        expect(subject.find(:all).records.size).to be 15
      end
    end

    context 'when selector is an individual record' do
      it 'returns a single record' do
        expect(subject.find("2005553155")).to be_a SolrDocument
      end
    end
  end
end
