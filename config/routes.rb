
Iro::Engine.routes.draw do
  root to: '/iro/application#home'

  resources :alerts

  post 'datapoints', to: '/iro/datapoints#create'
  get  'datapoints', to: '/iro/datapoints#index'

  resources :option_watches

  get  'positions/:id/roll', to: 'positions#roll', as: :roll_position
  post 'positions/:id/roll', to: 'positions#do_roll'
  get  'positions/:id/refresh', to: 'positions#refresh', as: :refresh_position
  resources :positions
  resources :profiles

  get 'purses/:id/gameui', to: 'purses#show', as: :gameui_purse, defaults: { template: 'gameui' }
  get 'purses/:id', to: 'purses#show', as: :purse, defaults: { template: 'show' }
  resources :purses

  resources :stocks
  resources :strategies

  namespace :api do
    # resources :stocks
    get 'stocks/:ticker/period/:period', to: 'stocks#show'
    get 'stocks/:ticker/from/:begin_on', to: 'stocks#show'
    get 'stocks/:ticker/begin_on/:begin_on', to: 'stocks#show'
    get 'stocks/:ticker/from/:begin_on/to/:end_on', to: 'stocks#show'
    get 'stocks/:ticker/begin_on/:begin_on/end_on/:end_on', to: 'stocks#show'
  end

end
