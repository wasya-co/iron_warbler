Rails.application.routes.draw do

  root :to => 'application#home'

  mount IronWarbler::Engine => "/iron_warbler"

  devise_for :users, :skip => [ :registrations ], :controllers => {
    :sessions  => 'users/sessions',  :confirmations => 'users/confirmations',
    :passwords => 'users/passwords', :unlocks       => 'users/unlocks'
  }

end
