IronWarbler::Engine.routes.draw do

  root to: '/iro/application#home'

  resources :alerts
  resources :option_watches
  resources :profiles
  resources :stock_watches

end
