
RSpec.describe Iro::Datapoint, type: :model do

  describe 'positive' do

    it 'sanity' do
      n = Iro::Datapoint.all.length
      Iro::Datapoint.create( kind: 'something', value: 1 )
      Iro::Datapoint.all.length.should eql(n + 1 )
    end

  end

  describe 'validations' do
    it 'requires kind (k) and value (v)' do
      lambda { Iro::Datapoint.create!
        }.should raise_exception( Mongoid::Errors::Validations )
      lambda { Iro::Datapoint.create!( kind: 'something' )
        }.should raise_exception( Mongoid::Errors::Validations )
      lambda { Iro::Datapoint.create!( value: 1 )
        }.should raise_exception( Mongoid::Errors::Validations )
    end
  end

end

