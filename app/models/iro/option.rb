
class Iro::Option
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Iro::OptionBlackScholes
  store_in collection: 'iro_options'

  attr_accessor :recompute

  belongs_to :stock, class_name: 'Iro::Stock', inverse_of: :strategies
  def ticker; stock.ticker; end
  # field :ticker
  # validates :ticker, presence: true

  field :symbol
  ## each option can be a leg in a position, no uniqueness
  # validates :symbol, uniqueness: true, presence: true

  field :put_call, type: :string # 'PUT' or 'CALL'
  validates :put_call, presence: true

  field :delta, type: :float

  field :strike, type: :float
  validates :strike, presence: true

  field :expires_on, type: :date
  validates :expires_on, presence: true
  def self.expirations_list full: false, n: 5
    out = [[nil,nil]]
    day = Date.today
    n.times do
      next_exp = day.next_occurring(:thursday).next_occurring(:friday)
      if !next_exp.workday?
        next_exp = Time.previous_business_day( next_exp )
      end

      out.push([ next_exp.strftime('%b %e'), next_exp.strftime('%Y-%m-%d') ])
      day = next_exp
    end
    return out
    # [
    #   [ nil, nil ],
    #   [ 'Mar 22', '2024-03-22'.to_date ],
    #   [ 'Mar 28', '2024-03-28'.to_date ],
    #   [ 'Apr 5',  '2024-04-05'.to_date ],
    #   [ 'Mar 12', '2024-03-12'.to_date ],
    #   [ 'Mar 19', '2024-03-19'.to_date ],
    # ]
  end

  field :begin_price, type: :float
  field :begin_delta, type: :float
  field :end_price, type: :float
  field :end_delta, type: :float


  has_one :outer, class_name: 'Iro::Position', inverse_of: :outer
  has_one :inner, class_name: 'Iro::Position', inverse_of: :inner

  field :last, type: :float

  ## for TDA
  def symbol
    if !self[:symbol]
      p_c_ = put_call == 'PUT' ? 'P' : 'C'
      strike_ = strike.to_i == strike ? strike.to_i : strike
      sym = "#{stock.ticker}_#{expires_on.strftime("%m%d%y")}#{p_c_}#{strike_}" # XYZ_011819P45
      self[:symbol] = sym
      save
    end
    self[:symbol]
  end

  def sync
    out = Tda::Option.get_quote({
      contractType: put_call,
      strike: strike,
      expirationDate: expires_on,
      ticker: ticker,
    })
    puts! out, 'option sync'
    self.end_price = ( out.bid + out.ask ) / 2 rescue 0
    self.end_delta = out.delta
    # self.save
  end

  before_save :sync, if: ->() { !Rails.env.test? } ## do not sync in test

end
