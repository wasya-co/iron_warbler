
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

      print '.'
      sleep 5.minutes
    end
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

