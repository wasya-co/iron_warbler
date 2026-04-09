
##
## In this order:
##   be rake iro:positions_eval
##   be rake iro:positions_place_order
##   be rake iro:positions_check_status
##

namespace :positions do

  desc 'recommend positions actions'
  task eval: :environment do
    while true

      Iro::Position.active.includes( :strategy ).each do |pos|
        if pos.strategy.intent.present?
          pos.calc_rollp
          if pos.rollp > 0.5

            case pos.strategy.intent
            when Iro::Strategy::INTENT_CLOSE

              pos.inner.sync
              pos.outer.sync
              pos.update({ pending_price: pos.close_price, intent: Iro::Strategy::INTENT_CLOSE })
              print 'close^'

            when Iro::Strategy::INTENT_ROLL
              pos.calc_nxt
              print 'roll^'

            else
              puts "+++ no such intent `#{pos.strategy.intent}`- iio"
            end
          end
        end
      end

      print '.'
      sleep 60
    end
  end

  desc 'position place order'
  task place_order: :environment do
    while true

      Iro::Position.active.where( :intent.nin => ['', nil], status: 'active' ).each do |pos|
        puts! pos, '#positions_place_order'

        case pos.intent
        when Iro::Strategy::INTENT_CLOSE

          query = case pos.intent
          when Iro::Strategy::INTENT_CLOSE
            Tda::Order.close_credit_spread_q pos
          else
            throw '_TODO: hhs - placing order, not implemented'
          end
          outs = Tda::Order.place_order!( query )
          # puts! outs, 'placed-ze-order'
          flag = pos.update({
            schwab_order_id: outs[:schwab_order_id],
            schwab_status: outs[:schwab_status],
            status: Iro::Position::STATUS_PENDING,
          })
          print 'placed^'

        when Iro::Strategy::INTENT_ROLL

          outs = Tda::Order.place_order! pos.schwab_query
          # puts! outs, 'placed-ze-order'
          flag = pos.update({
            schwab_order_id: outs[:schwab_order_id],
            schwab_status: outs[:schwab_status],
            status: Iro::Position::STATUS_PENDING,
          })
          print 'placed^'

        else
          puts "+++ no such intent `#{pos.intent}` - mzo"
        end
      end

      print '.'
      sleep 60
    end
  end

  ## _TODO: this is a mess. must check for (1) opening a spread, and (2) rolling a spread.
  ##                        does autoprev exist? if so, should be updated. and there are more legs than 2.
  ##
  desc 'position check status'
  task check_status: :environment do
    while true

      Iro::Position.where({ status: 'pending', schwab_status: 'WORKING' }).each do |pos|

        throw 'this must be re-written'

        outs = Tda::Order.check_status pos.schwab_order_id
        puts! outs, 'outs'

        if outs[:errors]
          pos.update({ status: 'error' })
        else
          attrs = { schwab_status: outs[:status] }
          if 'FILLED' == outs[:status]
            attrs[:status] = Iro::Position::STATUS_CLOSED ## _TODO: cannot happen if rolling.
            attrs[:intent] = nil ## _TODO: does this set it to nil?!
            outs[:orderLegCollection].each do |leg|
              hash = Iro::Option.symbol_to_h leg[:instrument][:symbol]
              price = outs[:orderActivityCollection][0][:executionLegs].select { |exec_leg|
                exec_leg[:instrumentId] == leg[:instrument][:instrumentId]
              }[0][:price]
              if pos.inner.matches_h( hash )
                attrs[:inner_attributes] = { end_price: price }
              end
              if pos.outer.matches_h( hash )
                attrs[:outer_attributes] = { end_price: price }
              end
            end
          end
          puts! attrs,' attrs'
          pos.update!(attrs)
          pos.autoprev.update({ status: 'closed' })
          print 'checked^'
        end
      end

      print '.'
      sleep 600
    end
  end

  desc 'reprice'
  task reprice: :environment do
    while true

      Iro::Position.where({ status: 'pending', schwab_status: 'WORKING' }).each do |pos|

        case pos.intent
        when Iro::Strategy::INTENT_ROLL
          pos.autoprev.inner.sync
          pos.autoprev.outer.sync
          pos.inner.sync
          pos.inner.update( begin_price: pos.inner.end_price )
          pos.outer.sync
          pos.outer.update( begin_price: pos.outer.end_price )
          pos.update( pending_price: pos.roll_price )
          # print "+++ roll_price: #{pos.roll_price}"
        else
          throw '--p not implemented'
        end

        Tda::Order.cancel_order!( pos.schwab_order_id )
        outs = Tda::Order.place_order!( pos.schwab_query )
        flag = pos.update({
          schwab_order_id: outs[:schwab_order_id],
          schwab_status:   outs[:schwab_status],
          status:          Iro::Position::STATUS_PENDING,
        })
        print "repriced #{pos.roll_price}^"

      end

      print '.'
      sleep 15
    end
  end

end
