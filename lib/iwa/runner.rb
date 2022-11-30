
##
## _vp_ 2022-11-30
##
class Iwa::Runner

  def self.skip_fail
    raise "Iwa Runner raised #skip_fail"
  end


=begin
  Rule: (good roll)
    time left < 7.days
    or
      delta of position <= .12
      position earned >= 70%
    Find a call
      strike for +7.days
      <= .21 delta
      good liquidity (=volume)
    roll there.

  rule = {
    pre_ifs: [
      " lot.days_left < 7 ",
      " lot.delta <= 0.12 ",
      " lot.price < lot.open_price ", // non-losing
    ],
    finds: {
      "candidate_call": [
        " self.on_date == lot.on_date + 7.days ",
        " self.delta <= 0.21 ",
        " order_by( delta, desc ).first() ", // or order by strike, highest strike given the delta
      ],
    },
    actions: [
      " roll({ buy_back: lot, sell_to_open: candidates['candidate_call'] }) "
    ],
  }

  rule = {
    pre_ifs: [
      " lot.days_left < 7 ",
      " lot.price / lot.open_price <= 0.7 ", // 70% profit
    ],
    finds: [
      "candidate_call": [
        " self.on_date == lot.on_date + 7.days ",
        " self.delta <= 0.21 ",
        " order_by( delta, desc ).first() ", // or order by strike, highest strike given the delta
      ],
    ],
    ifs: [
      " !!@candidates['candidate_call'] ",
    ],
    actions: [
      " roll({ buy_back: lot, sell_to_open: candidate_call }) ",
      " Tda::trade.roll({ buy_back: lot, sell_to_open: @candidates['candidate_call'] }) ",
    ],
  }
=end
  def self.run
    while true

      purse = Iwa::Purse.main
      purse.lots.each do |lot|
        @lot = lot
        puts! lot, 'zeLot'

        @lot.rules.each do |rule|
          puts! rule, 'zeRule'

          @pre_answers = []
          rule.pre_ifs.each do |pre_if|
            puts! pre_if, 'pre_if'

            answer = eval( pre_if )
            @pre_answers.push( answer )
            if !answer
              Iwa::Runner.skip_fail
            end
          end

          @candidates = {}
          rule.finds.each do |k, vs|
            upstream_chain = Tda::Option.all.where({
              ticker: @lot.ticker,
              contractType: @lot.putCall,
              expirationDate: Time.at( @lot.expirationDate / 1000 ) + 7.days,
            })
            vs.each do |v|
              upstream_chain = upstream_chain.where(v)
            end
            @candidates[k] = upstream_chain.order_by( strikePrice: :desc ).first
          end

          @answers = []
          rule.ifs.each do |the_if|
            answer = eval(the_if)
            @answers.push( answer )
            if !answer
              Iwa::Runner.skip_fail
            end
          end

          rule.actions.each do |action|
            out = eval( action )
          end

        end
      end

      print '.'
      sleep 5 # seconds
    end
  end

end
