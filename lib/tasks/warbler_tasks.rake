
def puts! a, b=''
  puts "+++ +++ #{b}:"
  pp a
end

namespace :warbler do

  desc 'test placing orders for stock' do
  task place_order_stock: :environment do
    opts = {
      "instruction": "BUY",
      "price": "1.10",
      "quantity": 1,
      "symbol": "BAC",
    }
    out = Warbler::Ameritrade::Api.place_stock_limit_order opts
    puts! out, 'out'
  end

  ## @TODO: this is still in ish_manager namespace, need to actually move it here.
  desc 'watch the stocks, and trigger actions - not alphavantage, tda now. 2021-08-08'
  task watch_stocks: :environment do
    while true
      stocks = Warbler::StockWatch.where( notification_type: :EMAIL )
      stocks.each do |stock|
        begin
          Timeout::timeout( 10 ) do
            out = Warbler::Ameritrade::Api.get_quote({ symbol: stock.ticker })
            r = out[:lastPrice]
            if  stock.direction == :ABOVE && r >= stock.price ||
                stock.direction == :BELOW && r <= stock.price
              IshManager::ApplicationMailer.stock_alert( stock ).deliver
            end
          end
        rescue Exception => e
          puts! e, 'Error in ish_manager:watch_stocks :'
        end
      end
      print '.'
      sleep Warbler::StockWatch::SLEEP_TIME_SECONDS
    end
  end

  desc 'watch option: contractType=PUT|CALL strike symbol date=yyyy-mm-dd'
  task watch_options: :environment do
    while true
      option_watches = Warbler::OptionWatch.where( notification_type: :EMAIL )
      option_watches.each do |option|
        begin
          Timeout::timeout( 10 ) do
            ## opts = { contractType: 'PUT', strike: 355.0, symbol: 'NVDA', date: '2022-02-18' }
            out = Warbler::Ameritrade::Api.get_option( option )
            r = out[:last]
            if  option.direction == :ABOVE && r >= option.price ||
                option.direction == :BELOW && r <= option.price
              IshManager::ApplicationMailer.option_alert( option ).deliver
            end
          end
        rescue Exception => e
          puts! e, 'Error in ish_manager:watch_options :'
        end
      end
      print '.'
      sleep Warbler::OptionWatch::SLEEP_TIME_SECONDS
    end
  end

end
