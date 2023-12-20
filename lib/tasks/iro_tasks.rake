
namespace :iro do

  desc 'watch stocks'
  task watch_stocks: :environment do
    while true

      begin
        Timeout::timeout( 10 ) do
          TDA::Api.get_quotes Iro::Stock.active.map(&:ticker).join(",")
        end
      rescue Exception => e
        puts! e, 'Error in iro:watch_stocks'
        # Wco::Exceptionist.notify(e, 'Error in iro:watch_stocks')
      end

      sleep Iro::Stock::SLEEP_TIME_SECONDS
    end
  end

  desc 'alerts'
  task alerts: :environment do
    while true
      Iro::Alert.active.each do |alert|
        # price = Iro::Stock.latest( alert.ticker ).price
        price = Tda::Api.get_quote( alert.symbol ).last
        if  alert.direction == Iro::Alert::DIRECTION_ABOVE && price >= alert.strike ||
            alert.direction == Iro::Alert::DIRECTION_BELOW && price <= alert.strike
          Iro::AlertMailer.stock_alert( alert ).deliver_later
        end
      end
      sleep Iro::Alert::SLEEP_TIME_SECONDS
    end
  end

end


