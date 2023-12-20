
RSpec.describe Iro::Datapoint, type: :model do

  describe 'positive' do

    it 'sanity' do
      n = Iro::Datapoint.all.length
      Iro::Datapoint.create( k: 'something', v: 1 )
      Iro::Datapoint.all.length.should eql(n + 1 )
    end

  end

  describe 'validations' do
    it 'requires key (k) and value (v)' do
      lambda { Iro::Datapoint.create
        }.should raise_exception( ActiveRecord::NotNullViolation )
      lambda { Iro::Datapoint.create( k: 'something' )
        }.should raise_exception( ActiveRecord::NotNullViolation )
      lambda { Iro::Datapoint.create( v: 1 )
        }.should raise_exception( ActiveRecord::NotNullViolation )
    end
  end

end

