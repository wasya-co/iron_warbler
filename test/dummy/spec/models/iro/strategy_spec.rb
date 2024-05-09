
RSpec.describe Iro::Strategy do

  before do
    destroy_every( Iro::Stock, Iro::Position, Iro::Strategy )
    @nvda     = create( :stock, ticker: 'NVDA'  )
  end

  ## short NVDA credit spread
  it '#next_inner_strike(expires_on)' do
    @nvda.last = 892.0
    @strategy = Iro::Strategy.create!({ slug: 'xxTestxx',
      kind: Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD,
      long_or_short: Iro::Strategy::SHORT,
      stock: @nvda,

      next_inner_delta: 0.15,
      next_inner_strike: 900,
      next_buffer_above_water: 0,
    })
    out = @strategy.next_inner_strike_on( '2024-05-10' )
    out.should eql 920
  end

  context 'per-kind calculations' do
    before do
      @strategy = create( :strategy, stock: @nvda )
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

