class CreateIroPriceItem < ActiveRecord::Migration[6.1]
  def change
    create_table :iro_price_items do |t|

      t.string "putCall", index: true
      t.string "symbol", index: true
      t.string "description"
      t.string "exchangeName"
      t.string "bidAskSize"
      t.string "expirationType"
      t.float "bid"
      t.float "ask"
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
      t.bigint "expirationDate", index: true
      t.bigint "lastTradingDay"
      t.boolean "inTheMoney"
      t.boolean "nonStandard"
      t.boolean "isIndexOption"
      t.date "tradeDate"
      t.string "interval"
      t.string "ticker", limit: 32, index: true
      t.timestamp "timestamp"

      t.timestamps
    end
  end
end

