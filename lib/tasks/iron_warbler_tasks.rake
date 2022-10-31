
require 'csv'

def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end


namespace :iron_warbler do

  ## 2022-02-13 prep for recharts, only transform existing data/*.json
  desc 'Usage: be rake iron_warbler:churn_ticker ticker=<TICKER> n_days=<N_DAYS>'
  task churn_ticker: :environment do
    ticker = ENV['ticker']
    n_days = ENV['n_days'].to_i

    if !ticker || !n_days
      puts ""
      puts "Usage: be rake iron_warbler:churn_ticker ticker=<TICKER> n_days=<N_DAYS>"
      puts ""
      exit 33
    end

    puts "Churning #{ticker} #{n_days}..."

    inn = CSV.read("data/#{ticker}.csv")
    inn2 = inn[1...n_days]
    inn3 = inn2.map do |q|
      { date: q[0], open: q[1], high: q[2], low: q[3], close: q[4], adj_close: q[5], volume: q[6], }
    end

    File.write("data/#{ticker}-#{n_days}.json", JSON.pretty_generate(inn3))
    puts 'ok'
  end

  desc 'test placing orders for stock' do
    task :place_order_stock => :environment do
      opts = {
        "instruction": "BUY",
        "price": "1.10",
        "quantity": 1,
        "symbol": "BAC"
      }
      out = Warbler::Ameritrade::Api.place_stock_limit_order opts
      puts! out, 'out'
    end
  end

  desc 'the runner that populates my db for graphing'
  task :get_option_price_items => :environment do
    while true
      tickers = IronWarbler::Ticker.active
      tickers.each do |ticker|
        begin
          Timeout::timeout( 30 ) do
            out = IronWarbler::Ameritrade::Api.get_options({ ticker: ticker.ticker, interval: IronWarbler::INTERVAL_5_MINUTES })
          end
        rescue Exception => e
          puts! e, 'Error in ish_manager:watch_options :'
        end
      end
      print '^'
      sleep IronWarbler::INTERVAL_5_MINUTES_SECONDS
    end
  end

  desc 'OptionWatch: contractType=PUT|CALL strike ticker date=yyyy-mm-dd'
  task :watch_options => :environment do
    while true
      option_watches = IronWarbler::OptionWatch.active
      puts! option_watches, 'Option Watches are'

      option_watches.each do |_ow|
        begin
          Timeout::timeout( 10 ) do
            ow = { contractType: _ow.contractType, strike: _ow.strike, ticker: _ow.ticker, date: _ow.date }
            out = IronWarbler::Ameritrade::Api.get_option( ow )

            r = out[:last]
            puts! r, 'last'

          end
        rescue Exception => e
          puts! e, 'Error in iron_warbler:watch_options :'
        end
      end
      print '.'
      sleep IronWarbler::INTERVAL_1_MINUTE_SECONDS
      # sleep IronWarbler::INTERVAL_5_SECONDS
    end
  end

  # 2021-08-08
  # 2022-01-17
  desc 'watch the stocks, and trigger actions - TDA'
  task watch_stocks: :environment do
    while true
      stocks = IronWarbler::StockWatch.where( notification_type: :EMAIL )
      stocks.each do |stock|
        begin
          Timeout::timeout( 10 ) do
            out = IronWarbler::Ameritrade::Api.get_quote({ symbol: stock.ticker })
            r = out[:lastPrice]
            if  stock.direction == :ABOVE && r >= stock.price ||
                stock.direction == :BELOW && r <= stock.price
                IronWarbler::ApplicationMailer.stock_alert( stock ).deliver
          end
          end
        rescue Exception => e
          puts! e, 'Error in :watch_stocks :'
        end
      end
      print '.'
      sleep IronWarbler::INTERVAL_1_MINUTE_SECONDS
    end
  end


end
