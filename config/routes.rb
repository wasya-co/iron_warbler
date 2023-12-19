
IronWarbler::Engine.routes.draw do
  root to: '/iro/application#home'

  resources :alerts

  post 'datapoints', to: '/iro/datapoints#create'
  get  'datapoints', to: '/iro/datapoints#index'

  resources :option_watches
  resources :profiles
  resources :stock_watches

end
