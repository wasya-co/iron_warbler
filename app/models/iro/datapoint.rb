

class Iro::Datapoint
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_datapoints'

  field :kind ## PUT, CALL, STOCK, CURRENCY, CRYPTO
  validates :kind, presence: true
  index({ kind: -1 })

  field :symbol ## ticker, but use 'symbol' ONLY

  field :date, type: Date ## @obsolete, use quote_at
  index({ kind: -1, date: -1 })

  field :quote_at, type: DateTime
  index({ kind: -1, quote_at: -1 })
  validates :quote_at, uniqueness: { scope: [ :kind, :symbol ] }

  field :open, type: Float
  field :high, type: Float
  field :low, type: Float

  field :value, type: Float
  validates :value, presence: true
  def close
    value
  end
  def close= a
    value= a
  end

  field :volume, type: Integer


  def self.test_0trash
    add_fields = { '$addFields':  {
      'date_string': {
        '$dateToString': { 'format': "%Y-%m-%d", 'date': "$created_at" }
      }
    } }
    # group = { '$group': {
    #   '_id': "$date_string",
    #   'my_doc': { '$first': "$$ROOT" }
    # } }
    group = { '$group': {
      '_id': "$date",
      'my_doc': { '$first': "$$ROOT" }
    } }
    lookup = { '$lookup': {
      'from':         'iro_dates',
      'localField':   'date_string',
      'foreignField': 'date',
      'as':           'dates',
    } }
    lookup_merge = { '$replaceRoot': {
      'newRoot': { '$mergeObjects': [
        { '$arrayElemAt': [ "$dates", 0 ] }, "$$ROOT"
      ] }
    } }
    match = { '$match': {
      'kind': 'some-type',
      'created_at': {
        '$gte': '2023-12-01'.to_datetime,
        '$lte': '2023-12-31'.to_datetime,
      }
    } }

    outs = Iro::Datapoint.collection.aggregate([
      add_fields,
      lookup, lookup_merge,
      match,

      { '$sort': { 'date_string': 1 } },
      group,
      # { '$replaceRoot': { 'newRoot': "$my_doc" } },
      # { '$project': { '_id': 0, 'date_string': 1, 'value': 1 } },
    ])

    puts! 'result'
    pp outs.to_a
    # puts! outs.to_a, 'result'
  end

  def self.test
    lookup = { '$lookup': {
      'from':         'iro_datapoints',
      'localField':   'date',
      'foreignField': 'date',
      'pipeline': [
        { '$sort': { 'value': -1 } },
      ],
      'as':           'datapoints',
    } }
    lookup_merge = { '$replaceRoot': {
      'newRoot': { '$mergeObjects': [
        { '$arrayElemAt': [ "$datapoints", 0 ] }, "$$ROOT"
      ] }
    } }


    match = { '$match': {
      'date': {
        '$gte': '2023-12-25',
        '$lte': '2023-12-31',
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

  def self.import_stock symbol:, path:
    csv = CSV.read(path, headers: true)
    csv.each do |row|
      flag = create({
        kind:    'STOCK',
        symbol:   symbol,
        date:     row['date'],
        quote_at: row['date'],

        volume: row['volume'],

        open:  row['open'],
        high:  row['high'],
        low:   row['low'],
        value: row['close'],
      })
      print '.' if flag.persisted?
    end
    puts 'ok'
  end

end