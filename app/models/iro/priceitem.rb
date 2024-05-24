
##
## specifically Option or Stock priceitem?
##
class Iro::Priceitem
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_price_items'

  ## PUT, CALL, STOCK
  field :putCall,         type: String
  field :symbol,          type: String
  field :ticker,          type: String
  # belongs_to :stock, inverse_of: :priceitems

  field :bid,             type: Float
  field :bidSize,         type: Integer
  field :ask,             type: Float
  field :askSize,         type: Integer
  field :last,            type: Float

  field :openPrice,       type: Float
  field :lowPrice,        type: Float
  field :highPrice,       type: Float
  field :closePrice,      type: Float

  field :quoteTimeInLong, type: Integer
  field :timestamp,       type: Integer
  field :totalVolume,     type: Integer
  field :mark,            type: Float
  field :exchangeName,    type: String
  field :volatility,      type: Float

  def self.my_find props={}
    lookup = { '$lookup': {
      'from':         'iro_price_items',
      'localField':   'date',
      'foreignField': 'date',
      'pipeline': [
        { '$sort': { 'value': -1 } },
      ],
      'as':           'dates',
    } }
    lookup_merge = { '$replaceRoot': {
      'newRoot': { '$mergeObjects': [
        { '$arrayElemAt': [ "$dates", 0 ] }, "$$ROOT"
      ] }
    } }


    match = { '$match': {
      'date': {
        '$gte': props[:begin_on],
        '$lte': props[:end_on],
      }
    } }

    group = { '$group': {
      '_id': "$date",
      'my_doc': { '$first': "$$ROOT" }
    } }

    outs = Iro::Date.collection.aggregate([
      match,

      lookup,
      lookup_merge,

      group,
      { '$replaceRoot': { 'newRoot': "$my_doc" } },
      # { '$replaceRoot': { 'newRoot': "$my_doc" } },


      { '$project': { '_id': 0, 'date': 1, 'value': 1 } },
      { '$sort': { 'date': 1 } },
    ])

    puts! 'result'
    pp outs.to_a
    # puts! outs.to_a, 'result'
  end

end
