
Rails.application.routes.draw do
  # root to: redirect('/iro')
  root to: 'application#home'

  mount Iro::Engine => "/trading"
  mount Wco::Engine => '/wco'

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
  }
  resources :users

end
