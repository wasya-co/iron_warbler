
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

  desc 'Get BTC, ETH price from coinmarketcap'
  task :get_coins => :environment do
    while true

      ::Iro::Iro.get_coins

      print '.'
      # sleep 5 * 60 ## 5 minutes
      sleep 55 * 60 ## 1 hr
    end
  end

  desc 'get coins once'
  task :get_coins_once => :environment do
    ::Iro::Iro.get_coins
    print '^'
  end

  desc 'get treasuries'
  task :get_treasuries => :environment do
    ::Iro::Iro.get_treasuries
    print '^'
  end

  ## Expected headers: Date, Open, High, Low, Close
  desc 'import_stock stock=<stock> path=<path>'
  task :import_stock => :environment do
    # puts! ARGV, 'ARGV'
    # puts! ENV, 'ENV'
    if ARGV.length != 3
      puts! ''
      puts! "Usage: import_stock <stock> <path>"
      puts! 'Expected headers: Date, Open, High, Low, Close'
      puts! ''
      exit 0
    end
    Iro::Datapoint.import_stock symbol: ENV['stock'], path: ENV['path']
  end

  desc 'import historic treasuries'
  task :import_1990_2023_treasuries => :environment do
    ::Iro::Iro.import_1990_2023_treasuries
  end

  desc 'import 2024 treasuries'
  task :import_2024_treasuries => :environment do
    ::Iro::Iro.import_2024_treasuries
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
          outs = Tda::Stock.get_quotes Iro::Stock.active.map(&:ticker).join(",")
        end
      rescue Exception => e
        puts! e, 'Error in iro:watch_stocks'
        # Wco::Exceptionist.notify(e, 'Error in iro:watch_stocks')
      end

      print '.'
      sleep 15 # *60 # 15 min
    end
  end

end


