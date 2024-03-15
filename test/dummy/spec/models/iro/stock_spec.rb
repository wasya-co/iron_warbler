
RSpec.describe Iro::Stock do

  before do
    destroy_every( Iro::Stock )
  end

  it 'sanity' do
    a = Iro::Stock.create( ticker: 'a' )
    a.persisted?.should eql true
  end

  it '#active' do
    @gme = Iro::Stock.create( ticker: 'GME' )

    as = Iro::Stock.active
    as.length.should > 0
  end

end

