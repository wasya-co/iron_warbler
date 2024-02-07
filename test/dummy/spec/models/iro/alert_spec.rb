

RSpec.describe Iro::Alert, type: :model do

  it 'sanity' do
    a = Iro::Alert.create!( symbol: 'QQQ', direction: 'BELOW', strike: 1.0 )
    a.persisted?.should eql true
  end

end
