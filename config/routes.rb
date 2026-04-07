
Iro::Engine.routes.draw do
  root to: '/iro/application#home'

  resources :alerts

  post 'datapoints', to: '/iro/datapoints#create'
  get  'datapoints', to: '/iro/datapoints#index'
  get  'datapoints/by-symbol', to: '/iro/datapoints#index'
  get  'datapoints/by-symbol/:symbol', to: '/iro/datapoints#index'

  resources :option_watches

  match 'positions/:id/close',     to: 'positions#close',    as: :close_position, via: [ :get, :post ]
  get   'positions/:id/duplicate', to: 'positions#new',      as: :duplicate_position
  post  'positions/propose',       to: 'positions#propose',  as: :propose_position
  get   'positions/:id/prepare',   to: 'positions#prepare',  as: :position_prepare_to_roll, defaults: { template: 'gameui' }
  match 'positions/:id/prepare2',  to: 'positions#prepare2', as: :prepare2_position,        defaults: { template: 'gameui' }, via: [ :get, :post ]
  match 'positions/:id/prepare3',  to: 'positions#prepare3', as: :prepare3_position,        defaults: { template: 'gameui' }, via: [ :get, :post ]
  post  'positions/:id/roll',      to: 'positions#do_roll',  as: :roll_position
  get   'positions/:id/sync',      to: 'positions#sync',     as: :sync_position
  get   'positions/:id/eval',      to: 'positions#eval',     as: :position_eval
  match 'positions/:id/place2',    to: 'positions#place2',   as: :place2_position, via: [ :get, :post ]
  post  'positions/:id/place3',    to: 'positions#place3',   as: :place3_position
  post  'positions/:id/reprice',   to: 'positions#reprice',  as: :reprice_position
  delete 'positions', to: 'positions#destroy_multi'
  get 'positions/:id/check', to: 'positions#check', as: :check_position
  resources :positions
  resources :profiles

  get 'purses/:id/sync', to: 'purses#sync', as: :sync_purse
  get 'purses/:id/gameui', to: 'purses#show', as: :purse_gameui, defaults: { template: 'gameui' }
  get 'purses/:id/table',  to: 'purses#show', as: :purse_table,  defaults: { template: 'table' }
  get 'purses/:id',        to: 'purses#show', as: :purse
  resources :purses

  get 'schwab/sync',      to: 'application#schwab_sync',      as: :schwab_sync
  get 'schwab/sync_exec', to: 'application#schwab_sync_exec', as: :schwab_sync_exec

  get 'stocks/sync', to: 'stocks#sync', as: :sync_stocks
  resources :stocks

  # get 'strategies/new-spread', to: 'strategies#new', as: :new_spread_strategy, defaults: { kind: 'spread' }
  # get 'strategies/new-wheel',  to: 'strategies#new', as: :new_wheel_strategy,  defaults: { kind: 'wheel' }
  resources :strategies

  get 'api/oauth2-redirect.html',      to: 'api#oauth2_redirect'
  get 'api/schwab-exec-redirect.html', to: 'api#schwab_exec_redirect'
  namespace :api do
    get 'stocks',                                           to: 'stocks#index'
    get 'stocks/:ticker',                                   to: 'stocks#show'
    get 'stocks/:ticker/begin_on/:begin_on',                to: 'stocks#show'
    get 'stocks/:ticker/begin_on/:begin_on/end_on/:end_on', to: 'stocks#show'
    get 'stocks/:ticker/from/:begin_on',                    to: 'stocks#show'
    get 'stocks/:ticker/from/:begin_on/to/:end_on',         to: 'stocks#show'
    get 'stocks/:ticker/max-pain',                          to: 'stocks#max_pain'
    get 'stocks/:ticker/period/:period',                    to: 'stocks#show'
  end

end
