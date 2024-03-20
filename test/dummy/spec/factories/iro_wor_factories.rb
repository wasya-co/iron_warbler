
FactoryBot.define do

  factory :purse, class: 'Iro::Purse' do
    slug { generate(:slug) }
  end

  factory :stock, class: 'Iro::Stock' do
    ticker { 'XXX' }
  end

  factory :strategy, class: 'Iro::Strategy' do
    long_or_short { Iro::Strategy::LONG }
    slug { generate(:slug) }
  end

end

