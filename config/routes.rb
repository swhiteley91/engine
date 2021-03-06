# Back-office: sign in/out + list of sites + my account

Locomotive::Engine.routes.draw do

  # Authentication
  devise_for :locomotive_account,
    class_name:   'Locomotive::Account',
    skip:         [:registrations],
    path:         '',
    failure_app:  'Locomotive::Devise::FailureApp'

  devise_scope :locomotive_account do
    get   'sign_up'  => 'registrations#new', as: :sign_up
    post  'sign_up'  => 'registrations#create'
  end

  root to: 'sites#index'

  resources :sites

  resource :my_account, controller: 'my_account' do
    put :regenerate_api_key, on: :member
  end

  # Back-office: current site, pages, content entries, assets and the site settings
  scope ':site_handle' do

    get '/',          to: 'dashboard#show'
    get 'dashboard',  to: 'dashboard#show', as: :dashboard

    resources :pages do
      put :sort, on: :member
      get :get_path, on: :collection
    end

    resources :accounts

    resources :memberships

    resources :translations

    resources :content_assets do
      post :bulk_create, on: :collection
    end

    resources :content_entries, path: 'content_types/:slug/entries' do
      get :show_in_form,  on: :collection
      put :sort,          on: :collection
      get :export,        on: :collection
    end

    namespace :custom_fields, path: 'content_types/:slug/fields/:name' do
      resource :select_options, only: [:edit, :update] do
        get :new_option
      end
    end

    resource :current_site, controller: 'current_site' do
      get :new_domain
      get :new_locale
    end

    # Preview mode handled by Steam
    mount Locomotive::Steam::Server.to_app => '/preview', as: 'preview', anchor: false

  end
end
