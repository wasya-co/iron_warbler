# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_02_15_233715) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "option_price_items", force: :cascade do |t|
    t.string "putCall"
    t.string "symbol"
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
    t.bigint "expirationDate"
    t.bigint "lastTradingDay"
    t.boolean "inTheMoney"
    t.boolean "nonStandard"
    t.boolean "isIndexOption"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "timestamp"
    t.date "tradeDate"
  end

end
