
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

      Iro::Position.active.includes( :strategy ).each do |position|
        if position.strategy.intent.present?
          position.calc_rollp
          if position.rollp > 0.5

            case position.strategy.intent
            when Iro::Strategy::INTENT_CLOSE

              position.inner.sync
              position.outer.sync
              position.update({ pending_price: position.close_price, intent: Iro::Strategy::INTENT_CLOSE })
              print 'close^'

            when Iro::Strategy::INTENT_ROLL
              position.calc_nxt
              print 'roll^'

            else
              puts "+++ no such intent `#{position.strategy.intent}`- iio"
            end
          end
        end
      end

      print '.'
      sleep 60
    end
  end

  desc 'recommend position actions'
  task place_order: :environment do
    while true

      Iro::Position.active.where( :intent.nin => ['', nil], status: 'active' ).each do |position|
        puts! position, '#positions_place_order'

        case position.intent
        when Iro::Strategy::INTENT_CLOSE

          query = case position.intent
          when Iro::Strategy::INTENT_CLOSE
            Tda::Order.close_credit_spread_q position
          else
            throw '_TODO: hhs - placing order, not implemented'
          end
          outs = Tda::Order.place_order!( query )
          puts! outs, 'outs'

          flag = position.update({
            schwab_order_id: outs[:schwab_order_id],
            schwab_status: outs[:schwab_status],
            status: Iro::Position::STATUS_PENDING,
          })
          print 'placed^'

        else
          puts "+++ no such intent `#{position.intent}` - mzo"
        end
      end

      print '.'
      sleep 60
    end
  end

  desc 'positions_check_status'
  task check_status: :environment do
    while true

      Iro::Position.where({ status: 'pending', schwab_status: 'WORKING' }).each do |position|

        outs = Tda::Order.check_status position.schwab_order_id
        puts! outs, 'outs'

        if outs[:errors]
          position.update({ status: 'error' })
        else
          attrs = { schwab_status: outs[:status] }
          if 'FILLED' == outs[:status]
            attrs[:status] = Iro::Position::STATUS_CLOSED
            outs[:orderLegCollection].each do |leg|
              hash = Iro::Option.symbol_to_h leg[:instrument][:symbol]
              price = outs[:orderActivityCollection][0][:executionLegs].select { |exec_leg|
                exec_leg[:instrumentId] == leg[:instrument][:instrumentId]
              }[0][:price]
              if position.inner.matches_h( hash )
                attrs[:inner_attributes] = { end_price: price }
              end
              if position.outer.matches_h( hash )
                attrs[:outer_attributes] = { end_price: price }
              end
            end
          end
          puts! attrs,' attrs'
          position.update!(attrs)
          print 'checked^'
        end
      end

      print '.'
      sleep 60
    end
  end

end
