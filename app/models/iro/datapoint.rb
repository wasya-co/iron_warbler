

class Iro::Datapoint
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_datapoints'

  field :date
  index({ kind: -1, date: -1 })

  field :value, type: Float
  validates :value, presence: true

  field :kind
  validates :kind, presence: true
  index({ kind: -1 })

  def self.test_0trash
    add_fields = { '$addFields':  {
      'date_string': {
        '$dateToString': { 'format': "%Y-%m-%d", 'date': "$created_at" }
      }
    } }
    group = { '$group': {
      '_id': "$date_string",
      'my_doc': { '$first': "$$ROOT" }
    } }
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

end