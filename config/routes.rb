IronWarbler::Engine.routes.draw do
  root :to => 'application#home'

  resources :option_watches
  resources :stock_watches

  namespace :api do
    resources :stock_watches
  end

end
