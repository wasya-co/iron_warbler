

RSpec.describe Tda::Api, type: :model do

  it '#get_quotes' do
    outs = Tda::Api.get_quotes 'GME'
    outs.length.should eql 1
    outs[0].last.class.should eql Float
  end


end
