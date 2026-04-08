
##
## In this order:
##   be rake iro:positions_eval
##   be rake iro:positions_place_order
##   be rake iro:positions_check_status
##

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
  task positions_eval: :environment do
    while true

      Iro::Iro.schwab_sync
      Iro::Iro.schwab_sync_exec
      Iro::Stock.sync

      Iro::Position.active.includes( :strategy ).each do |position|
        if position.strategy.intent
          position.calc_rollp
          if position.rollp > 0.5
            puts! position, '#positions_eval'

            case position.strategy.intent
            when Iro::Strategy::INTENT_CLOSE

              position.inner.sync
              position.outer.sync
              position.update({ pending_price: position.close_price, intent: Iro::Strategy::INTENT_CLOSE })
              print '^'

            when Iro::Strategy::INTENT_ROLL
              position.calc_nxt
            else
              puts "+++ no intent - iio"
            end
          end
        end
      end

      print '.'
      sleep 60
    end
  end

  desc 'recommend position actions'
  task positions_place_order: :environment do
    while true

      Iro::Iro.schwab_sync_exec

      Iro::Position.active.where( :intent.ne => nil, status: 'active' ).each do |position|
        puts! position, '#positions_place_order'

        case position.intent
        when Iro::Strategy::INTENT_CLOSE

          query = case position.intent
          when Iro::Strategy::INTENT_CLOSE
            Tda::Order.close_credit_spread_q position
          else
            throw '_TODO: hhs - placing order, not implemented'
          end
          outs = Tda::Order.place_order!( query )
          puts! outs, 'outs'

          flag = position.update({
            schwab_order_id: outs[:schwab_order_id],
            schwab_status: outs[:schwab_status],
            status: Iro::Position::STATUS_PENDING,
          })
          print '^'

        else
          puts "+++ no intent - izo"
        end
      end

      print '.'
      sleep 60
    end
  end

  desc 'positions_check_status'
  task positions_check_status: :environment do
    while true
      Iro::Iro.schwab_sync_exec

      Iro::Position.where({ status: 'active', schwab_status: 'WORKING' }).each do |position|

        outs = Tda::Order.check_status position.schwab_order_id
        puts! outs, 'outs'

        if outs[:errors]
          position.update({ status: 'error' })
        else
          attrs = { schwab_status: outs[:status] }
          if 'FILLED' == outs[:status]
            attrs[:status] = Iro::Position::STATUS_CLOSED
            outs[:orderLegCollection].each do |leg|
              hash = Iro::Option.symbol_to_h leg[:instrument][:symbol]
              price = outs[:orderActivityCollection][0][:executionLegs].select { |exec_leg|
                exec_leg[:instrumentId] == leg[:instrument][:instrumentId]
              }[0][:price]
              if position.inner.matches_h( hash )
                attrs[:inner_attributes] = { end_price: price }
              end
              if position.outer.matches_h( hash )
                attrs[:outer_attributes] = { end_price: price }
              end
            end
          end
          puts! attrs,' attrs'
          position.update!(attrs)
          print '^'
        end
      end

      print '.'
      sleep 60
    end
  end

  desc 'refresh positions'
  task refresh_positions: :environment do
    Iro::Position.active.where({ kind: 'covered_call' }).map &:refresh
  end

  desc 'sync schwab'
  task sync_schwab: :environment do
    Iro::Iro.schwab_sync
    puts '.'
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


