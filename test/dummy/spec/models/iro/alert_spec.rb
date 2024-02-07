
RSpec.describe Iro::Alert do

  before do
    destroy_every( Iro::Alert, Iro::Stock )
    @stock = create( :iro_stock )
  end

  it 'sanity' do
    a = Iro::Alert.create!( symbol: 'QQQ', direction: 'BELOW', strike: 1.0 )
    a.persisted?.should eql true
  end

  it '#do_run' do
    @alert = create( :iro_alert, symbol: @stock.ticker, direction: "ABOVE", strike: 0.0 )

    expect( Iro::AlertMailer ).to receive( :stock_alert ).exactly( 1 ).times
    @alert.do_run
  end

end
