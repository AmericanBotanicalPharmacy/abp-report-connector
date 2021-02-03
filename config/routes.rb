Rails.application.routes.draw do
  devise_for :users
  get 'home/index'
  root to: 'home#index'

  namespace :api do
    get 'ping', to: 'ping#index'
    post 'db/run', to: 'db#run'
    post 'message/deliver', to: 'messages#deliver'
    resources :sources, only: [:index, :create, :update, :destroy]
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
