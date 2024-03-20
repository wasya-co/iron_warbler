
class Iro::Purse
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'iro_purses'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: -1 }, { unique: true })

  has_many :positions, class_name: 'Iro::Position', inverse_of: :purse

  belongs_to :stock, class_name: 'Iro::Stock', inverse_of: :strategies

  field :unit,             type: :integer, default: 10
  ## with unit 10,  .001
  ## with unit 100, .0001
  field :summary_unit,    type: :float, default: 0.001

  ## for rolling only:
  field :height,           type: :integer, default: 100

  field :mark_every_n_usd, type: :float, default: 1
  field :n_next_positions, type: :integer, default: 5

  field :available_amount, type: :float

  def wt_avg_begin_inner_d_long
    max_loss_total = 0
    out = positions.long.map do |pos|
      max_loss_total += pos.max_loss * pos.q
      pos.max_loss * pos.q * pos.inner.begin_delta
    end
    # byebug
    out = out.reduce( &:+ ) / max_loss_total
    return out
  end
  def wt_avg_begin_inner_d_short
    max_loss_total = 0
    positions.short.map do |pos|
      max_loss_total += pos.max_loss * pos.q
      pos.max_loss * pos.q * pos.inner.begin_delta
    end.reduce( &:+ ) / max_loss_total
  end

  def to_s
    slug
  end
  def self.list
    [[nil,nil]] + all.map { |p| [p, p.id] }
  end
end
