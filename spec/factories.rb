
FactoryBot.define do

  ## Copy-pasted from ish_models

  # factory :user do
  #   sequence :email do |n|
  #     "some-#{n}@email.com"
  #   end
  #   password { 'some-password' }
  # end

  # factory :user_profile, :class => Ish::UserProfile do
  #   sequence :email do |n|
  #     "test-#{n}@email.com"
  #   end
  #   name { 'some-name' }
  #   after :build do |doc|
  #     doc.user = create(:user)
  #   end
  # end

  ## Alphabetized, below

  factory :option_watch, class: IronWarbler::OptionWatch do
    contractType { 'PUT' }
    date { '2021-01-01' }
    price { 55 }
    strike { 100 }
    ticker { 'SPY' }

    # after :build do |doc|
    #   doc.profile = create(:user_profile)
    # end

  end

end
