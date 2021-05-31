require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'users/sign_in', to: 'users/sessions#new', as: :new_user_session
    get 'users/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  namespace :api do
    get 'ping', to: 'ping#index'
    get 'me', to: 'users#me'
    post 'db/run', to: 'db#run'
    post 'message/deliver', to: 'messages#deliver'
    post 'spreadsheets', to: 'spreadsheets#update'
    post 'spreadsheets/sync', to: 'spreadsheets#sync'
    resources :sources, only: [:index, :create, :update, :destroy]
  end

  mount Sidekiq::Web => "/sidekiq"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
