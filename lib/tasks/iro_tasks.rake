
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


  desc 'collect options priceitems once'
  task get_options: :environment do
    Iro::Iro.schwab_exec_sync
    # Iro::Position.sync_all ## do not use!

    options = Iro::Option.active
    response = Tda::Option.get_chains({ ticker: 'META' })

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
      Iro::Iro.schwab_exec_sync
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


  ## 2026-09-23 this works!
  desc 'seed_priceitems'
  task seed_priceitems: :environment do
    n = 50
    min = 1.0
    max = 5.0

    option_id = '6ac2b61baad128408215fe05'
    stock  = Iro::Stock.find_by ticker: 'META' ## '66b39693689a518710d4a665'

    option = Iro::Option.find option_id
    t0 = Time.now - n.minutes
    n.times.map do |i|
      last = rand(min..max).round(2)
      Iro::Priceitem.create!(
        symbol:   option.symbol,
        ticker:   stock.ticker,
        putCall:  option.put_call,
        last:     last,
        quote_at: t0 + i.minutes,

        stock_id: stock.id,
        option_id: option.id,
      )
    end
  end


  desc 'schwab sync'
  task schwab_sync: :environment do
    while true
      # Iro::Iro.schwab_sync
      Iro::Iro.schwab_exec_sync
      Iro::Stock.sync
      Iro::Position.sync_all

      print '.'
      sleep 3.minutes
    end
  end

end

