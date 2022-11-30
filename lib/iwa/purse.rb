
class Iwa::Purse

  def self.main

    rule = OpenStruct.new({
      pre_ifs: [
        " @lot.daysToExpiration < 7 ",
        " @lot.delta <= 0.12 ",
        " @lot.last < @lot.openPrice ", # non-losing
      ],
      finds: {
        "candidate_call": [
          # " expirationDate == @lot.expirationDate + 7.days ",
          " delta <= 0.21 ",
          # " order_by( delta, desc ).first() ", // or order by strike, highest strike given the delta
        ],
      },
      ifs: [],
      actions: [
        " Tda::Trade.roll({ buy_back: @lot, sell_to_open: @candidates['candidate_call'] }) ",
      ],
    })

    lot = OpenStruct.new({
      rules: [ rule ],
      putCall: 'CALL',
      expirationDate: 1670619600000,

      # need to add these:
      daysToExpiration: 6,
      delta: 0.11,
      last: 0.59,
      openPrice: 0.60,
      ticker: 'GME',
    })

    out = OpenStruct.new({
      lots: [ lot ],
    })
    return out
  end

end


