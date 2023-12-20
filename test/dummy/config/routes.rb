
Rails.application.routes.draw do
  root to: redirect('/iro')

  mount Iro::Engine => "/iro"

end
