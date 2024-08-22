
json.stocks @stocks do |stock|
  # json.status stock.status
  json.label  stock.ticker
  # json.ticker stock.ticker
  json.value  stock.ticker
end
