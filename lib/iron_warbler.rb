
require 'business_time'
require 'haml'
require 'mongoid'
require 'httparty'
require 'holidays'

require "iro/engine"

class Schwab
  include HTTParty
  debug_output $stdout
end

class Iro::Iro

  def self.get_coins
    out = HTTParty.get( "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest?slug=bitcoin,ethereum", {
      headers: { 'X-CMC_PRO_API_KEY' => COINMARKETCAP[:key] },
    })
    out = out.parsed_response.deep_symbolize_keys
    out[:data].each do |k, item|
      opi = Iro::Datapoint.new({
        date:     Time.now.to_date,
        kind:     Iro::Datapoint::KIND_CRYPTO,
        symbol:   item[:symbol],
        quote_at: item[:quote][:USD][:last_updated],
        value:    item[:quote][:USD][:price],
        volume:   item[:quote][:USD][:volume_24h],
      })
      opi.save!
    end
  end

  def self.get_currencies
    out = HTTParty.get "https://api.currencyfreaks.com/v2.0/rates/latest?apikey=#{CURRENCYFREAKS[:key]}&symbols=COP,EUR,JPY"
    out = out.parsed_response.deep_symbolize_keys!
    out[:rates].each do |currency, value|

      # opi = OPI.new({
      #   putCall:     'CURRENCY',
      #   symbol:      currency,
      #   ticker:      currency,
      #   exchangeName: 'currencyfreaks',
      #   mark:        value,
      #   lastPrice:   value,
      #   timestamp:   Time.now.to_date,
      # })
      # opi.save!

      datapoint = Iro::Datapoint.new({
        date: Time.now.to_date,
        quote_at: Time.now,
        kind: Iro::Datapoint::KIND_CURRENCY,
        symbol: currency,
        value: value,
      })
      datapoint.save!

      print '^'
    end
  end

  def self.get_treasuries
    response = HTTParty.get( "https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/all/#{Time.now.strftime('%Y%m')}?type=daily_treasury_yield_curve&field_tdr_date_value_month=#{Time.now.strftime('%Y%m')}&page&_format=csv")
    outs = CSV.parse( response.body, { headers: true })
    out = outs[0]
    date = Date.strptime(out['Date'], '%m/%d/%Y')
    {
      '1 Mo'  => Iro::Datapoint::SYMBOL_T1MO,
      '2 Mo'  => Iro::Datapoint::SYMBOL_T2MO,
      '3 Mo'  => Iro::Datapoint::SYMBOL_T3MO,
      '4 Mo'  => Iro::Datapoint::SYMBOL_T4MO,
      '6 Mo'  => Iro::Datapoint::SYMBOL_T6MO,
      '1 Yr'  => Iro::Datapoint::SYMBOL_T1YR,
      '2 Yr'  => Iro::Datapoint::SYMBOL_T2YR,
      '3 Yr'  => Iro::Datapoint::SYMBOL_T3YR,
      '5 Yr'  => Iro::Datapoint::SYMBOL_T5YR,
      '7 Yr'  => Iro::Datapoint::SYMBOL_T7YR,
      '10 Yr' => Iro::Datapoint::SYMBOL_T10YR,
      '20 Yr' => Iro::Datapoint::SYMBOL_T20YR,
      '30 Yr' => Iro::Datapoint::SYMBOL_T30YR,
    }.each do |k, v|
      opi = Iro::Datapoint.new({
        date:     date,
        quote_at: date,
        kind:     Iro::Datapoint::KIND_TREASURY,
        symbol:   v,
        value:    out[k],
      })
      opi.save!
      print '^'
    end
  end

  def self.import_1990_2023_treasuries
    outs = CSV.parse( File.read( Rails.root.join('data', 'treasuries', '1990..23 daily-treasury-rates.csv') ), { headers: true })
    outs.each do |out|
      date = Date.strptime(out['Date'], '%m/%d/%y')
      {
        '1 Mo'  => Iro::Datapoint::SYMBOL_T1MO,
        '2 Mo'  => Iro::Datapoint::SYMBOL_T2MO,
        '3 Mo'  => Iro::Datapoint::SYMBOL_T3MO,
        '4 Mo'  => Iro::Datapoint::SYMBOL_T4MO,
        '6 Mo'  => Iro::Datapoint::SYMBOL_T6MO,
        '1 Yr'  => Iro::Datapoint::SYMBOL_T1YR,
        '2 Yr'  => Iro::Datapoint::SYMBOL_T2YR,
        '3 Yr'  => Iro::Datapoint::SYMBOL_T3YR,
        '5 Yr'  => Iro::Datapoint::SYMBOL_T5YR,
        '7 Yr'  => Iro::Datapoint::SYMBOL_T7YR,
        '10 Yr' => Iro::Datapoint::SYMBOL_T10YR,
        '20 Yr' => Iro::Datapoint::SYMBOL_T20YR,
        '30 Yr' => Iro::Datapoint::SYMBOL_T30YR,
      }.each do |k, v|
        if out[k]
          opi = Iro::Datapoint.new({
            date:     date,
            quote_at: date,
            kind:     Iro::Datapoint::KIND_TREASURY,
            symbol:   v,
            value:    out[k],
          })
          begin
            opi.save!
          rescue Mongoid::Errors::Validations => err
            puts! err, 'err'
          end
          print '^'
        end
      end
    end
  end

  def self.import_2024_treasuries
    outs = CSV.parse( File.read( Rails.root.join('data', 'treasuries', '2024 daily-treasury-rates.csv') ), { headers: true })
    outs.each do |out|
      date = Date.strptime(out['Date'], '%m/%d/%Y')
      {
        '1 Mo'  => Iro::Datapoint::SYMBOL_T1MO,
        '2 Mo'  => Iro::Datapoint::SYMBOL_T2MO,
        '3 Mo'  => Iro::Datapoint::SYMBOL_T3MO,
        '4 Mo'  => Iro::Datapoint::SYMBOL_T4MO,
        '6 Mo'  => Iro::Datapoint::SYMBOL_T6MO,
        '1 Yr'  => Iro::Datapoint::SYMBOL_T1YR,
        '2 Yr'  => Iro::Datapoint::SYMBOL_T2YR,
        '3 Yr'  => Iro::Datapoint::SYMBOL_T3YR,
        '5 Yr'  => Iro::Datapoint::SYMBOL_T5YR,
        '7 Yr'  => Iro::Datapoint::SYMBOL_T7YR,
        '10 Yr' => Iro::Datapoint::SYMBOL_T10YR,
        '20 Yr' => Iro::Datapoint::SYMBOL_T20YR,
        '30 Yr' => Iro::Datapoint::SYMBOL_T30YR,
      }.each do |k, v|
        if out[k]
          opi = Iro::Datapoint.new({
            date:     date,
            quote_at: date,
            kind:     Iro::Datapoint::KIND_TREASURY,
            symbol:   v,
            value:    out[k],
          })
          begin
            opi.save!
          rescue Mongoid::Errors::Validations => err
            puts! err, 'err'
          end
          print '^'
        end
      end
    end
  end

  def self.schwab_sync
    profile = Wco::Profile.find_by email: 'piousbox@gmail.com'
    out = Schwab.post( "https://api.schwabapi.com/v1/oauth/token", {
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      basic_auth: { username: SCHWAB_DATA[:key], password: SCHWAB_DATA[:secret] },
      body: {
        grant_type: 'refresh_token',
        refresh_token: profile.schwab_refresh_token
      },
    })
    out = out.parsed_response
    puts! out, '#schwab_sync'

    attrs = {
      schwab_access_token:  out['access_token'],
      schwab_refresh_token: out['refresh_token'],
      schwab_id_token:      out['id_token'],
    }
    # puts! attrs, 'attrs'

    if attrs[:schwab_refresh_token]
      profile.update(attrs)
      profile.save!
      return attrs
    else
      return false
    end
  end

  def self.schwab_sync_exec
    profile = Wco::Profile.find_by email: 'piousbox@gmail.com'
    out = Schwab.post( "https://api.schwabapi.com/v1/oauth/token", {
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      basic_auth: { username: SCHWAB_EXEC[:key], password: SCHWAB_EXEC[:secret] },
      body: {
        grant_type: 'refresh_token',
        refresh_token: profile.schwab_exec_refresh_token
      },
    })
    out = out.parsed_response
    puts! out, '#schwab_sync_exec'

    attrs = {
      schwab_exec_access_token:  out['access_token'],
      schwab_exec_refresh_token: out['refresh_token'],
      schwab_exec_id_token:      out['id_token'],
    }
    # puts! attrs, 'attrs'

    if attrs[:schwab_exec_refresh_token]
      profile.update(attrs)
      profile.save!
      return attrs
    else
      return false
    end
  end


end


Holidays.between(Date.civil(2015, 1, 1), 2.years.from_now, :us, :observed).map do |holiday|
  BusinessTime::Config.holidays << holiday[:date]
  # Implement long weekends if they apply to the region, eg:
  # BusinessTime::Config.holidays << holiday[:date].next_week if !holiday[:date].weekday?
end
BusinessTime::Config.holidays << '2025-04-18'.to_date
BusinessTime::Config.holidays << '2026-04-03'.to_date
# puts! 'all the holidays'
