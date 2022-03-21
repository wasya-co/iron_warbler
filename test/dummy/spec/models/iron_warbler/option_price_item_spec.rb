require "spec_helper"

test_data = {
  :putCall=>"PUT",
  :symbol=>"NVDA_031822P240",
  :description=>"NVDA Mar 18 2022 240 Put",
  :exchangeName=>"OPR",
  :bid=>8.95,
  :ask=>9.2,
  :last=>9.3,
  :mark=>9.07,
  :bidSize=>20,
  :askSize=>48,
  :bidAskSize=>"20X48",
  :highPrice=>15.15,
  :lowPrice=>9.1,
  :openPrice=>0.0,
  :closePrice=>18.1,
  :totalVolume=>1528,
  :tradeDate=>nil,
  :tradeTimeInLong=>1644958659849,
  :quoteTimeInLong=>1644958799837,
  :netChange=>-8.8,
  :volatility=>64.466,
  :delta=>-0.268,
  :gamma=>0.007,
  :theta=>-0.259,
  :vega=>0.257,
  :rho=>-0.068,
  :openInterest=>4716,
  :timeValue=>9.3,
  :theoreticalOptionValue=>9.075,
  :theoreticalVolatility=>29.0,
  :strikePrice=>240.0,
  :expirationDate=>1647633600000,
  :daysToExpiration=>31,
  :expirationType=>"R",
  :lastTradingDay=>1647648000000,
  :multiplier=>100.0,
  :percentChange=>-48.62,
  :markChange=>-9.03,
  :markPercentChange=>-49.86,
  :intrinsicValue=>-24.95,
  :inTheMoney=>false,
  :timestamp=> 'Tue, 15 Feb 2022 23:04:35 +0000'
}

describe IronWarbler::OptionPriceItem do
  before :each do
  end

  context '#create' do
    it "sanity" do
      opi = IronWarbler::OptionPriceItem.create( test_data )
      puts! opi.errors.full_messages if !opi.persisted?
      opi.persisted?.should eql true
    end
  end

end





