Iro::Engine.routes.draw do
  resources :alerts
  root to: 'application#home'

  resources :profiles
end
