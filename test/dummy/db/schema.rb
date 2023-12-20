# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_12_20_223730) do

  create_table "dates", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "date"
    t.index ["date"], name: "index_dates_on_date", unique: true
  end

  create_table "iro_alerts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "class_name"
    t.string "kind"
    t.string "symbol"
    t.string "direction"
    t.float "strike"
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "active", null: false
  end

  create_table "iro_datapoints", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "k", null: false
    t.float "v", null: false
    t.date "d"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["d"], name: "index_iro_datapoints_on_d"
    t.index ["k"], name: "index_iro_datapoints_on_k"
  end

  create_table "iro_price_items", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
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
    t.date "tradeDate"
    t.string "interval"
    t.string "ticker", limit: 32
    t.timestamp "timestamp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expirationDate"], name: "index_iro_price_items_on_expirationDate"
    t.index ["putCall"], name: "index_iro_price_items_on_putCall"
    t.index ["symbol"], name: "index_iro_price_items_on_symbol"
    t.index ["ticker"], name: "index_iro_price_items_on_ticker"
  end

  create_table "iro_profiles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email"
    t.string "role_name"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "iro_stocks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "ticker", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["status"], name: "index_iro_stocks_on_status"
    t.index ["ticker"], name: "index_iro_stocks_on_ticker"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
