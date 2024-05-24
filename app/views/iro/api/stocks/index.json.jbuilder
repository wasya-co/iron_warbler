
json.stocks @stocks do |stock|
  json.status stock.status
  json.ticker stock.ticker
end
