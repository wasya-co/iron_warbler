
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

  desc 'schwab sync'
  task schwab_sync: :environment do
    while true
      Iro::Iro.schwab_sync
      Iro::Iro.schwab_sync_exec
      Iro::Stock.sync
      Iro::Position.sync_all

      print '.'
      sleep 3.minutes
    end
  end


  desc 'collect options priceitems once'
  task get_options: :environment do
    # Iro::Iro.schwab_sync
    # Iro::Position.sync_all

    options = Iro::Option.active

    options.each do |opt|
      pi = Iro::Priceitem.new({
        last:     opt.end_price,
        option:   opt,
        putCall:  opt.put_call,
        symbol:   opt.symbol,
        stock:    opt.stock,
        ticker:   opt.ticker,
        quote_at: Time.now,
      })
      pi.save
      print '^'
    end

    puts '#get_options run once.'
  end


  desc 'refresh all'
  task refresh_all: :environment do
    while true
      Iro::Iro.schwab_sync
      Iro::Iro.schwab_sync_exec
      Iro::Stock.sync
      Iro::Position.sync_all

      Iro::Position.active.each do |position|
        position.calc_rollp
        if position.rollp > 0.5
          position.calc_nxt
        end
        print 'eval.'
      end

      print 'refreshed.'
      sleep 5.minutes
    end
  end

end

