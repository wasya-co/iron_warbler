##
## @TODO: this is copy-pasted *in part* from ish_models
##

FactoryBot.define do

  # sequence :email do |n|
  #   "test-#{n}@email.com"
  # end

  # alphabetized : )

  # factory :admin, class: User do
  #   email { 'piousbox@gmail.com' }
  #   password { '1234567890' }
  #   after :build do |u|
  #     p = Ish::UserProfile.find_or_initialize_by email: u.email
  #     p.user = u
  #     p.role_name = :admin
  #     p.save
  #     u.profile = p
  #     u.save
  #   end
  # end

  factory :opi, class: IronWarbler::OptionPriceItem do
    putCall { 'PUT' }
    symbol { 'QQQ_041422C355' }
    bid { 1 }
    ask { 1.01 }
=begin
    t.float "last"
    t.float "mark"
    t.float "lastPrice"
    t.float "highPrice"
    t.float "lowPrice"
    t.float "openPrice"
    t.float "closePrice"
    t.float "netChange"
    t.float "volatility"
    t.float "delta"
    t.float "gamma"
    t.float "theta"
    t.float "vega"
    t.float "rho"
    t.float "timeValue"
    t.float "theoreticalOptionValue"
    t.float "theoreticalVolatility"
    t.float "strikePrice"
    t.float "percentChange"
    t.float "markChange"
    t.float "markPercentChange"
    t.float "intrinsicValue"
    t.float "multiplier"
    t.integer "bidSize"
    t.integer "askSize"
    t.bigint "totalVolume"
    t.integer "openInterest"
    t.integer "daysToExpiration"
    t.bigint "tradeTimeInLong"
    t.bigint "quoteTimeInLong"
    t.bigint "expirationDate"
    t.bigint "lastTradingDay"
    t.boolean "inTheMoney"
    t.boolean "nonStandard"
    t.boolean "isIndexOption"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "timestamp"
    t.date "tradeDate"
=end
  end

  factory :option_watch, class: IronWarbler::OptionWatch do
    contractType { IronWarbler::CALL }
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

  # factory :user do
  #   email { generate(:email) }
  #   password { '1234567890' }
  #   after :build do |u|
  #     p = Ish::UserProfile.find_or_initialize_by email: u.email
  #     p.user = u
  #     if 'piousbox@gmail.com' == u.email
  #       p.role_name = :admin
  #     end
  #     p.save
  #     u.profile = p
  #     u.save
  #   end
  # end

end
