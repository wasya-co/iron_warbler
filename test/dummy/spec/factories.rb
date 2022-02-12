##
## @TODO: this is copy-pasted *in part* from ish_models
##

FactoryBot.define do
  sequence :email do |n|
    "test-#{n}@email.com"
  end

  # alphabetized : )

  ## @TODO: I should not have this... use factor(:user)
=begin
  factory :admin, class: User do
    email { 'piousbox@gmail.com' }
    password { '1234567890' }
    after :build do |u|
      p = Ish::UserProfile.find_or_initialize_by email: 'piousbox@gmail.com'
      p.user = u
      p.save
    end
  end
=end

  ## these aren't generated without a user.
=begin
  factory :profile, :class => Ish::UserProfile do
    email { generate(:email) }
    name { 'some-name' }
    after :build do |doc|
      doc.user = create(:user)
    end
  end
=end

  factory :stock_watch, class: IronWarbler::StockWatch do
    ticker { 'QQQ' }
    direction { 'ABOVE' }
    price { 1000 }
  end

  factory :user do
    email { generate(:email) }
    password { '1234567890' }
    after :build do |u|
      p = Ish::UserProfile.find_or_initialize_by email: u.email
      p.user = u
      p.save
      u.profile = p
      u.save
    end
  end

  ## these aren't generated without a user.
=begin
  factory :user_profile, :class => Ish::UserProfile do
    email { generate(:email) }
    name { 'some-name' }
    after :build do |doc|
      doc.user = create(:user)
    end
  end
=end

  factory :video do
    name { 'some-name' }
    youtube_id { 'some-youtube-id' }
  end


end
