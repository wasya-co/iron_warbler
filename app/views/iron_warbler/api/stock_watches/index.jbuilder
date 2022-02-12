

json.array! @stock_watches do |sw|
  json.direction sw.direction
  json.price     sw.price
  json.ticker    sw.ticker
end
