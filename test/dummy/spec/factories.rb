
## @TODO: this is copy-pasted *in part* from ish_models, should be in one place really.
## should convert location of factories across gems

FactoryBot.define do

  # alphabetized : )

  factory :admin do
    email { 'piousbox@gmail.com' }
    password { '1234567890' }
    after :build do |u|
      p = Ish::UserProfile.create email: 'piousbox@gmail.com', name: 'sudoer', user: u
    end
  end

  factory :user do
    sequence :email do |n|
      "some-#{n}@email.com"
    end
    password { '1234567890' }
  end

  factory :user_profile, :class => Ish::UserProfile do
    sequence :email do |n|
      "test-#{n}@email.com"
    end
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
