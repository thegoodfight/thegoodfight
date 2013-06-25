Fsj::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, ActiveAdmin::Devise.config

  root to: 'home#index'
  match "/subscribe" => "home#subscribe", via: :post, as: :subscribe
  match "/search" => "search#index", via: :get, as: :search

  resources :episodes do
    member do
      get 'email' => 'episodes#email', as: :email
      get 'audio' => 'episodes#audio', as: :audio
    end

    collection do
      get 'by/:category'     => 'episodes#grouped', as: :grouped
      get 'by/:category/:id' => 'episodes#index',   as: :categorized
      get ':player/:id'      => 'episodes#show',    as: :typed
      get 'latest'
    end
  end


  resources :stats,         only: [:index, :update]
  resources :redirects,     only: [:show, :index]
  resources :posts,         only: [:show, :index]
  resources :people,        only: [:show, :index]
  resources :organizations, only: [:show, :index]
  resources :topics,        only: [:show, :index]

  match "/:page" => 'pages#show', as: :page
end
