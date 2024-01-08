
Iro::Engine.routes.draw do
  root to: '/iro/application#home'

  resources :alerts

  post 'datapoints', to: '/iro/datapoints#create'
  get  'datapoints', to: '/iro/datapoints#index'

  resources :option_watches

  post 'positions/:id/roll', to: 'positions#roll', as: :roll_position
  resources :positions
  resources :profiles
  resources :purses

  resources :stocks
  resources :strategies

end
