Rails.application.routes.draw do
  scope '(:locale)', locale: /en/ do
    devise_for :users, controllers: {
      invitations: 'users/invitations',
      registrations: 'users/registrations',
    }, skip: [:invitation]

    # MANAGER ROUTES

    devise_scope :user do
      delete 'users/invitations/destroy', to: "users/invitations#destroy", as: :remove_user_invitation
      get '/users/invitation/accept', to: "users/invitations#edit",    as: :accept_user_invitation
      get '/users/invitation/new', to: "users/invitations#new", as: :new_user_invitation
      post '/user/invitation',       to: "users/invitations#create"
      patch '/user/invitation',      to: "users/invitations#update"
      put '/user/invitation',        to: "users/invitations#update"
    end

    root to: 'pages#home'

    resources :plans, only: %i[index] do
      get '/subscribe', to: 'plans#subscribe', as: :subscribe
      post '/subscription', to: 'plans#subscription', as: :subscription
    end

    resources :packages, only: %i[index] do
      get '/checkout', to: 'packages#checkout'
      post '/transaction', to: 'packages#transaction'
    end

    resources :companies, only: %i[new create] do
      post 'cancel_plan', to: 'plans#cancel_plan', as: :cancel_plan
    end
    get '/company/edit', to: 'companies#edit', as: :edit_company
    patch '/company', to: 'companies#update', as: :update_company
    get '/company', to: 'companies#show', as: :company

    # USER ROUTES
    resources :documents do
      member do
        get :export
        get :export_original
        get :export_bicolumn
        get :export_rich_text
        get :select_glossaries
        patch :translate
      end
      get :editor, to: 'documents#editor'
      get 'editor/row', to: 'documents#row_number'
      post 'editor/search', to: 'documents#chunk_search'
      patch 'confirm_chunks', to: 'documents#confirm_all_chunks'
      resources :text_chunks, only: %i[] do
        get :glossaries, to: 'text_chunks#glossaries'
      end
      resources :document_glossaries, only: %i[create]
    end
    resources :document_glossaries, only: %i[create]
    resources :text_chunks, only: %i[update] do
      patch 'confirm', to: 'text_chunks#confirm'
      get :versions, to: 'text_chunks#versions'
    end
    resources :glossaries do
      resources :terms, only: %i[new create]
      post :editor_terms, to: 'terms#editor_create'
      get :import_terms, to: 'glossaries#import_terms'
      post :create_terms, to: 'glossaries#create_terms'
    end
    resources :terms, except: %i[index new create]
    get :editor_new, to: 'terms#editor_new'

    # ADMIN ROUTES

    namespace :admin do
      resources :companies, except: %i[new create] do
        patch "cancel", to: "companies#cancel_plan"
        post '/validate', to: 'companies#validate'
        post '/deny', to: 'companies#deny'
      end
      get '/plans/status', to: 'plans#status'
      get '/packages/status', to: 'packages#status'
      resources :documents, only: %i[update]
      resources :subscriptions, only: %i[index]
      resources :packages do
        post '/visualize', to: 'packages#visualize!', as: :visualize
        post '/invisiblize', to: 'packages#invisiblize!', as: :invisiblize
      end
      resources :applies, only: %i[index]
      resources :users, except: %i[show new create]
      get '/plans/status', to: 'plans#status'
      resources :plans, except: %i[destroy] do
        post '/activate', to: 'plans#activate', as: :activate
        post '/publish', to: 'plans#publish', as: :publish
        post '/deactivate', to: 'plans#deactivate', as: :deactivate
        resources :orders, only: %i[new create]
      end
      get '/plans/status', to: 'plans#status'
      get '/packages/status', to: 'packages#status'
    end

    # API ROUTES
    namespace :api, defaults: { format: :json } do
      namespace :v1 do
        post "/companies/:id/postback", to: "companies#postback"
        post "/companies/:id/transaction", to: "transactions#postback"
        get "counter", to: "users#counter"
      end
    end
  end

    # SIDEKIQ

  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
