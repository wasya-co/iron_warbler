
FactoryBot.define do

  # alphabetized : )

  factory :option_watch, class: IronWarbler::OptionWatch do
    contractType { 'PUT' }
    date { '2021-01-01' }
    price { 55 }
    strike { 100 }
    ticker { 'SPY' }
    after :build do |doc|
      doc.profile = create(:user_profile)
    end
  end

end
