require 'spec_helper'

describe IronWarbler::StockWatch do

  before do
    @profile = create(:profile)
    @fields = %i| direction price ticker | # @TODO: more, get 'em all
  end

  describe '#create' do

    it 'validations' do
      stock_watch = create(:stock_watch, profile: @profile)
      @fields.each do |f|
        stock_watch.should validate_presence_of( f )
      end
    end

    it 'fields' do
      stock_watch = create(:stock_watch, profile: @profile)
      @fields.each do |f|
        stock_watch[f].should_not eql( nil ), "#{f} cannot be empty"
      end
    end

  end

end



