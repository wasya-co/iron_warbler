
class Iro::Purse
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'iro_purses'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: -1 }, { unique: true })

  has_many :positions, class_name: 'Iro::Position', inverse_of: :purse

  field :unit,             type: :integer, default: 100
  field :height,           type: :integer, default: 100
  field :mark_every_n_usd, type: :float, default: 1
  field :n_next_positions, type: :integer, default: 5
  field :summary_scale,    type: :float, default: 0.001

  field :available_amount, type: :float

  def to_s
    slug
  end
  def self.list
    [[nil,nil]] + all.map { |p| [p, p.id] }
  end
end
