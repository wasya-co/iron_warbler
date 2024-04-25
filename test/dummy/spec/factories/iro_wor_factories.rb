
FactoryBot.define do

  factory :option, class: 'Iro::Option' do
    expires_on { '2024-04-19' }
    put_call { 'CALL' }
    after :build do |doc|
      doc.stock    = Iro::Stock.all.first
    end
  end

  factory :position, class: 'Iro::Position' do
    status { Iro::Position::STATUS_ACTIVE }
    expires_on { '2024-04-19' }
    quantity { 1 }
    after :build do |doc|
      doc.purse    = Iro::Purse.all.first
      doc.stock    = Iro::Stock.all.first
      doc.strategy = Iro::Strategy.all.first
    end
  end

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

