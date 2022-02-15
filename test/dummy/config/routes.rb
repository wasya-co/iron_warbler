Rails.application.routes.draw do

  mount IronWarbler::Engine, :at => '/iron_warbler/'

end
