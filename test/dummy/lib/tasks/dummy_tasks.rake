
require 'csv'

def puts! a, b=''
  puts "+++ +++ #{b}:"
  puts a.inspect
end

def pp_puts! a, b=''
  puts "+++ +++ #{b}:"
  pp a
end

namespace :dummy do

  ## 2022-02-13 prep for recharts, only transform existing data/*.json
  desc 'Usage: be rake iron_warbler:churn_ticker ticker=<TICKER> n_days=<N_DAYS>'
  task churn_ticker: :environment do
    ticker = ENV['ticker']
    n_days = ENV['n_days'].to_i

    if !ticker || !n_days
      puts ""
      puts "Usage: be rake iron_warbler:churn_ticker ticker=<TICKER> n_days=<N_DAYS>"
      puts ""
      exit 33
    end

    puts "Churning #{ticker} #{n_days}..."

    inn = CSV.read("data/#{ticker}.csv")
    inn2 = inn[1...n_days]
    inn3 = inn2.map do |q|
      { date: q[0], open: q[1], high: q[2], low: q[3], close: q[4], adj_close: q[5], volume: q[6], }
    end

    File.write("data/#{ticker}-#{n_days}.json", JSON.pretty_generate(inn3))
    puts 'ok'
  end

  desc 'OptionWatch: contractType=PUT|CALL strike ticker date=yyyy-mm-dd'
  task option_watch_test: :environment do

    option = { contractType: 'PUT', strike: 240, ticker: 'NVDA', date: '2022-03-18' }
    out = IronWarbler::Ameritrade::Api.get_option( option )

    pp_puts! out, 'ze out'

  end

end
