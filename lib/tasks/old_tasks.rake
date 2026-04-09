
namespace :old do

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


end


