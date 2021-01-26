Rails.application.routes.draw do
  namespace :api do
    get 'ping', to: 'ping#index'
    post 'db/run', to: 'db#run'
    post 'message/deliver', to: 'messages#deliver'
    resources :sources, only: [:create, :update, :destroy]
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
