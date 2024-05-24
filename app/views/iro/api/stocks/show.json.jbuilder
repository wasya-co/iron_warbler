
json.ticker @stock.ticker
json.last   @stock.last

json.datapoints @datapoints do |p|
  json.quote_at  Time.at(p.quote_at).strftime('%Y-%m-%d')
  # json.timestamp p.timestamp
  json.value      p.value
end


