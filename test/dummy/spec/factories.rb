##
## @TODO: this is copy-pasted *in part* from ish_models
##

FactoryBot.define do
  sequence :email do |n|
    "test-#{n}@email.com"
  end

  # alphabetized : )

  factory :admin, class: User do
    email { 'piousbox@gmail.com' }
    password { '1234567890' }
    after :build do |u|
      p = Ish::UserProfile.find_or_initialize_by email: u.email
      p.user = u
      p.role_name = :admin
      p.save
      u.profile = p
      u.save
    end
  end

  factory :option_watch, class: IronWarbler::OptionWatch do
    contractType { IronWarbler::OptionWatch::CALL }
    date { '2022-02-22' }
    price { 1 }
    strike { 100.0 }
    ticker { 'XXX' }
  end

  factory :stock_watch, class: IronWarbler::StockWatch do
    action { :EMAIL }
    ticker { 'QQQ' }
    direction { :ABOVE }
    price { 1000 }
  end

  factory :user do
    email { generate(:email) }
    password { '1234567890' }
    after :build do |u|
      p = Ish::UserProfile.find_or_initialize_by email: u.email
      p.user = u
      if 'piousbox@gmail.com' == u.email
        p.role_name = :admin
      end
      p.save
      u.profile = p
      u.save
    end
  end

end
