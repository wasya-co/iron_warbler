
namespace :iro do

  ## 2023-03-31 _vp_ Continue.
  # if Time.now.in_time_zone > Time.now.in_time_zone.beginning_of_day + 8.5.hours &&
  #    Time.now.in_time_zone < Time.now.in_time_zone.beginning_of_day + 15.hours
  # end
  #
  desc 'alert on stock price action'
  task alert_stocks: :environment do
    while true

      ::Iro::Iro.alert_stocks

      print '.'
      sleep 45 # seconds
    end
  end

  ## 2023-03-31 _vp_ Done, unused.
  desc 'alert stocks test'
  task alert_stocks_test: :environment do
    tickers_str = Iro::OptionWatch.active.where( kind: ::Iro::OptionWatch::KIND_STOCK ).map(&:ticker).join(',')
    if tickers_str.present?

      out = Tda::Stock.get_quotes( tickers_str )
      Iro::OptionWatch.active.where( kind: ::Iro::OptionWatch::KIND_STOCK ).each do |watch|

        if watch.direction == Iro::OptionWatch::DIRECTION_ABOVE && out[watch.ticker][:mark] >= watch.mark ||
          watch.direction == Iro::OptionWatch::DIRECTION_BELOW && out[watch.ticker][:mark] <= watch.mark

          IshManager::ApplicationMailer.stock_alert( watch.id.to_s ).deliver_later
          watch.update_attributes({ state: Iro::OptionWatch::STATE_INACTIVE })

        end
      end

    end
  end

  ## 2023-02-04 _vp_ :: Continue
  ## 2023-02-06 _vp_ :: LFG
  desc 'The runner that populates the db for graphing'
  task :get_chains => :environment do
    while true

      ::Iro::Iro.get_chains

      print '.'
      # sleep 5 * 60 # 5 minutes
      sleep 55 * 60 # 1 hr
    end
  end

  desc 'Get BTC, ETH price from coinmarketcap'
  task :get_coins => :environment do
    while true

      ::Iro::Iro.get_coins

      print '.'
      # sleep 5 * 60 # 5 minutes
      sleep 55 * 60 # 1 hr
    end
  end

  desc 'Get COP from currencyfreaks, cron'
  task :get_currencies => :environment do
    ::Iro::Iro.get_currencies
    puts 'ok'
  end

  desc 'get gme short %'
  task :get_gme_short_availability_and_fee => :environment do
    errors = ::Iro::Iro.get_gme_short_availability_and_fee
    puts errors.presence || '.'
  end

  ## 2023-03-10 _vp_ Continue.
  desc 'get stocks'
  task get_stocks: :environment do
    while true

      ::Iro::Iro.get_stocks

      print '.'
      # sleep 45 # seconds
      sleep 55 * 60 # 1 hr
    end
  end

  ## 2023-02-06 _vp_ :: Continue
  ## 2023-02-08 _vp_ :: Continue
  ## 2023-03-18 _vp_ :: Continue
  ## 2023-03-19 _vp_ :: Continue, it's intense
  desc 'watch positions'
  task watch_positions: :environment do
    while true

      ::Iro::CoveredCall.active.each do |position|
        position.refresh
        if position.should_roll?

          position.update({
            next_delta:   position.next_position[:delta],
            next_outcome: position.next_outcome,
            next_symbol:  position.next_symbol,
            status:       Iro::Position::STATE_PROPOSED,
          })

          out = IroMailer.should_roll({
            next_symbol:  position.next_symbol,
            prev_symbol:  position.prev_symbol,
          })
          Rails.env.production? ? out.deliver_later : out.deliver_now

          print '+'
        end
      end

      print '.'
      sleep 15 * 60 # 15 min
      # sleep 60 * 60 # 1 hr
    end
  end


end
