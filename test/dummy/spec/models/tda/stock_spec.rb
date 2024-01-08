

RSpec.describe Tda::Stock, type: :model do

  it '#get_quotes' do
    Tda::Stock.expects( :get_quotes ).returns([ OpenStruct.new(last: 1.1) ])
    outs = Tda::Stock.get_quotes 'GME'
    outs.length.should eql 1
    outs[0].last.class.should eql Float
  end


end
