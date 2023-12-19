
RSpec.describe Iro::Datapoint, type: :model do

  describe 'positive' do

    it 'sanity' do
      n = Iro::Datapoint.all.length
      Iro::Datapoint.create( key: 'something', value: 1 )
      Iro::Datapoint.all.length.should eql(n + 1 )
    end

  end

  describe 'validations' do
    it 'requires key and value' do
      lambda { Iro::Datapoint.create
        }.should raise_exception( ActiveRecord::NotNullViolation )
      lambda { Iro::Datapoint.create( key: 'something' )
        }.should raise_exception( ActiveRecord::NotNullViolation )
      lambda { Iro::Datapoint.create( value: 1 )
        }.should raise_exception( ActiveRecord::NotNullViolation )
    end
  end

end

