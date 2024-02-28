
json.array! @datapoints do |p|
  json.date     p[:quote_at].in_time_zone('UTC').to_date
  json.quote_at p[:quote_at]
  json.open     p[:open]
  json.high     p[:high]
  json.low      p[:low]
  json.close    p[:value]
  json.volume   p[:volume]
end

