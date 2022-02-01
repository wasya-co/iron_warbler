
require 'spec_helper'

describe 'IronWarbler::Ameritrade::Api' do

  describe '#get_option_chain' do
    it 'validations' do
      expect do
        result = ::IronWarbler::Ameritrade::Api.get_option({})
      end.to raise_error Ish::InputError
    end
  end

end

