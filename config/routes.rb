
Iro::Engine.routes.draw do
  root to: '/iro/application#home'

  resources :alerts

  post 'datapoints', to: '/iro/datapoints#create'
  get  'datapoints', to: '/iro/datapoints#index'

  resources :option_watches

  get  'positions/duplicate/:id', to: 'positions#new',    as: :duplicate_position
  post 'positions/propose', to: 'positions#propose',      as: :propose_position
  get  'positions/:id/prepare', to: 'positions#prepare',  as: :prepare_to_roll_position, defaults: { template: 'gameui' }
  match  'positions/:id/prepare2', to: 'positions#prepare2', as: :prepare2_position, defaults: { template: 'gameui' }, via: [ :get, :post ]
  post 'positions/:id/roll', to: 'positions#do_roll',     as: :roll_position
  get  'positions/:id/sync', to: 'positions#sync',  as: :sync_position
  resources :positions
  resources :profiles

  get 'purses/:id/gameui', to: 'purses#show', as: :gameui_purse, defaults: { template: 'gameui' }
  get 'purses/:id', to: 'purses#show', as: :purse, defaults: { template: 'show' }
  resources :purses

  get 'stocks/sync', to: 'stocks#sync', as: :sync_stocks
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
