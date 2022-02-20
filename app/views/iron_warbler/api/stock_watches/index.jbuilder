
json.array! @stock_watches do |sw|
  json.action     sw.action
  json.direction  sw.direction
  json.price      sw.price
  json.profile_id sw.profile_id
  json.ticker     sw.ticker
end
