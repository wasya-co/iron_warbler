
RSpec.describe Iro::Stock, type: :model do

  it 'sanity' do
    a = Iro::Stock.create( ticker: 'GME' )
    a.persisted?.should eql true
  end

  it '#active' do
    Iro::Stock.create( ticker: 'GME' )

    as = Iro::Stock.active
    as.length.should > 0
  end

end
