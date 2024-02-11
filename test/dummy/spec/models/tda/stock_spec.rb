
RSpec.describe Tda::Stock do

  describe '#get_quotes' do


    it 'sanity' do
      expect( Tda::Stock ).to receive( :get_quotes ).and_return([ OpenStruct.new(last: 1.1) ])
      outs = Tda::Stock.get_quotes 'GME'
      outs.length.should eql 1
      outs[0].last.class.should eql Float
    end
  end

end
