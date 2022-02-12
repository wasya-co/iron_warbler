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
      p = Ish::UserProfile.create email: 'piousbox@gmail.com', name: 'sudoer', user: u
    end
  end

  factory :profile, :class => Ish::UserProfile do
    email { generate(:email) }
    name { 'some-name' }
    after :build do |doc|
      doc.user = create(:user)
    end
  end

  factory :stock_watch, class: IronWarbler::StockWatch do
    ticker { 'QQQ' }
    direction { 'ABOVE' }
    price { 1000 }
    after :build do |sw|
      p = create(:profile)
      sw.profile = p
    end
  end

  factory :user do
    email { generate(:email) }
    password { '1234567890' }
  end

  factory :user_profile, :class => Ish::UserProfile do
    email { generate(:email) }
    name { 'some-name' }
    after :build do |doc|
      doc.user = create(:user)
    end
  end

  factory :video do
    name { 'some-name' }
    youtube_id { 'some-youtube-id' }
  end


end
