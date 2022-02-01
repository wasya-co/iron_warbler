require 'spec_helper'

# From: http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/

Mongoid.load!("config/mongoid.yml", :test)

describe IronWarbler do
  describe '#configure' do

    it 'mongoid sanity' do
      sw = IronWarbler::StockWatch.create
    end

  end
end



