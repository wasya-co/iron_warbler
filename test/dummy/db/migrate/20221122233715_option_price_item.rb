
class OptionPriceItem < ActiveRecord::Migration[6.0]

  def down
    drop_table :iwa_option_price_items
  end

  def up
    create_table :iwa_option_price_items do |t|
      t.column :putCall, :string
      t.column :symbol, :string
      t.column :description, :string
      t.column :exchangeName, :string
      t.column :bidAskSize, :string
      t.column :expirationType, :string

      t.column :bid, :float
      t.column :ask, :float
      t.column :last, :float
      t.column :mark, :float
      t.column :lastPrice, :float
      t.column :highPrice, :float
      t.column :lowPrice, :float
      t.column :openPrice, :float
      t.column :closePrice, :float
      t.column :netChange, :float
      t.column :volatility, :float
      t.column :delta, :float
      t.column :gamma, :float
      t.column :theta, :float
      t.column :vega, :float
      t.column :rho, :float
      t.column :timeValue, :float
      t.column :theoreticalOptionValue, :float
      t.column :theoreticalVolatility, :float
      t.column :strikePrice, :float
      t.column :percentChange, :float
      t.column :markChange, :float
      t.column :markPercentChange, :float
      t.column :intrinsicValue, :float
      t.column :multiplier, :float

      t.column :bidSize, :integer
      t.column :askSize, :integer
      t.column :totalVolume, :bigint
      t.column :openInterest, :integer
      t.column :daysToExpiration, :integer
      t.column :tradeTimeInLong, :bigint
      t.column :quoteTimeInLong, :bigint
      t.column :expirationDate, :bigint
      t.column :lastTradingDay, :bigint

      t.column :inTheMoney, :boolean
      t.column :nonStandard, :boolean
      t.column :isIndexOption, :boolean

      t.timestamps
      t.column :timestamp, :timestamp
      t.column :tradeDate, :date
      t.column :interval, :string
    end
  end
end
