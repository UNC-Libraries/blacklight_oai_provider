Rails.application.routes.draw do
  concern :oai_provider, BlacklightOaiProvider::Routes::Provider.new

  mount Blacklight::Engine => '/'
  Blacklight::Marc.add_routes(self)

  root to: "catalog#index"

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider
    concerns :searchable
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
end
