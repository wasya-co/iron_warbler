
namespace :iro do

  desc 'alerts'
  task alerts: :environment do
    print 'iro:alerts'
    while true
      Iro::Alert.active.each do |alert|
        alert.do_run
      end

      print '.'
      sleep Rails.env.production? ? 60 : 15
    end
  end

  desc 'recommend position actions'
  task recommend_position_actions: :environment do
    Iro::Position.active.where({ kind: 'covered_call' }).map &:should_roll?
  end

  desc 'refresh positions'
  task refresh_positions: :environment do
    Iro::Position.active.where({ kind: 'covered_call' }).map &:refresh
  end

  desc 'watch positions'
  task watch_positions: :environment do
    while true
      if in_business

        positions = Iro::Position.active.where({ kind: 'covered_call' })
        positions.each do |position|
          out = Tda::Option.get_quote({
            contractType:   'CALL',
            strike:         position.strike,
            expirationDate: position.expires_on,
            ticker:         position.ticker,
          })
          position.update({
            end_delta: out[:delta],
            end_price: out[:last],
          })
        end

        print '.'
      end
      sleep 60 # seconds
    end
  end

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

end


