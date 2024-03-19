
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

  desc 'place order'
  task place_order: :environment do
    stock = Iro::Stock.f 'GME'
    outer = Iro::Option.new({
      stock:      stock,
      put_call:  'CALL',
      strike:     15.5,
      expires_on: '2024-03-22',
    })
    inner = Iro::Option.new({
      stock:      stock,
      put_call:  'CALL',
      strike:     17.0,
      expires_on: '2024-03-22',
    })
    out = Tda::Option.create_credit_call( inner: inner, outer: outer, q: 1, price: 0.01 )
    puts! out, 'out'
  end

end




