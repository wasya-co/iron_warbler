
json.ticker @stock.ticker
json.last   @stock.last

json.max_pain do
  @max_pain.each do |date, maps|
    json.set! date do
      json.all do
        json.array! maps['all'] do |strike, value|
          json.strike strike
          json.value value
        end
      end
    end
  end
end


