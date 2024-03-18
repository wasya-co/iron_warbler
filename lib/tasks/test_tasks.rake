
namespace :test do

  desc 'stock#volatility_mo'
  task stock_vol_mo: :environment do
    out = Iro::Stock.find_by( ticker: 'NVDA' ).volatility_from_mo
    puts! out, 'out'
  end

  desc 'stock#volatility_yr'
  task stock_vol_yr: :environment do
    out = Iro::Stock.find_by( ticker: 'NVDA' ).volatility_from_yr
    puts! out, 'out'
  end

  desc 'option#call_price'
  task option_call_price: :environment do
    stock      = Iro::Stock.find_by( ticker: 'NVDA' )
    stock.last = 884

    option = Iro::Option.new({
      stock:      stock,
      strike:     910,
      expires_on: '2024-03-22',
      # delta:      0.41,
    })
    out = option.put_price
    puts! out, 'out'
  end

end




