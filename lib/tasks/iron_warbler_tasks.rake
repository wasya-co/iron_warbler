

def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end


namespace :iron_warbler do

  # 2021-08-08
  # 2022-01-17
  desc 'watch the stocks, and trigger actions - TDA'
  task watch_stocks: :environment do
    while true
      stocks = Warbler::StockWatch.where( notification_type: :EMAIL )
      stocks.each do |stock|

        puts! stock, 'stock'

        begin
          Timeout::timeout( 10 ) do
            out = Warbler::Ameritrade::Api.get_quote({ symbol: stock.ticker })
            r = out[:lastPrice]
            if  stock.direction == :ABOVE && r >= stock.price ||
                stock.direction == :BELOW && r <= stock.price
              Warbler::ApplicationMailer.stock_alert( stock ).deliver
          end
          end
        rescue Exception => e
          puts! e, 'e in :watch_stocks'
        end
      end
      sleep Warbler::StockWatch::SLEEP_TIME_SECONDS
    end
  end

end
