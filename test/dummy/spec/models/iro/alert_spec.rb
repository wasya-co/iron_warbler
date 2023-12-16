

RSpec.describe Iro::Alert, type: :model do

  it 'sanity' do
    a = Iro::Alert.create!
    a.persisted?.should eql true
  end

end
