Rails.application.routes.draw do
  namespace :api do
    get 'ping', to: 'ping#index'
    post 'db/run', to: 'db#run'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
