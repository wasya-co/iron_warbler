
RSpec.describe Iro::Strategy do

  before do
    destroy_every( Iro::Stock, Iro::Strategy )
    @nvda     = create( :stock, ticker: 'NVDA'  )
    @strategy = create( :strategy, stock: @nvda )
  end

  it '#next_inner_strike(expires_on)' do
    raise 'now implemented'
    # delta must be low enough
    # must be enough above water
  end

  context 'per-kind calculations' do
    before do
      @inner    = create( :option, strike: 90,  begin_price: 1.99, end_price: 0.5  )
      @outer    = create( :option, strike: 101, begin_price: 1.86, end_price: 0.25 )
      @position = create( :position, inner: @inner, outer: @outer )
    end

    it '#max_gain_short_credit_call_spread' do
      ( @strategy.max_gain_short_credit_call_spread( @position ) - 0.13 ).should < EPSILON
    end

    it '#max_loss_short_credit_call_spread' do
      @strategy.max_loss_short_credit_call_spread( @position ).should eql 11.0
    end

    it '#net_amount_short_credit_call_spread' do
      @strategy.net_amount_short_credit_call_spread( @position ).should eql( 1.99 - 0.5 - 1.86 + 0.25 )
    end
  end

end

