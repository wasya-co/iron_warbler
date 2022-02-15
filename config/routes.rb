IronWarbler::Engine.routes.draw do
  root :to => 'application#home'

  resources :option_watches
  resources :stock_watches

  namespace :api do
    resources :stock_watches
    resources :option_watches
  end

  scope :api do

    get '/', to: 'api#home'
    ## pasted from ishapi
    # post  'users/fb_sign_in',      to: 'users#fb_sign_in'
    get   'users/me',              to: 'api#account'
    # post  'users/profile',         to: 'users#show'
    # post  'users/profile/update',  to: 'users#update'
    # get   'users/profile',         to: 'users#show' # @TODO: only for testing! accessToken must be hidden
    # match 'users/long_term_token', to: 'application#long_term_token', via: [ :get, :post ]
    post  'users/login',           to: 'api#login'

  end




end
