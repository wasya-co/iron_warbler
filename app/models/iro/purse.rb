
class Iro::Purse
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_purses'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: -1 }, { unique: true })

  has_many :positions, class_name: 'Iro::Position', inverse_of: :purse

  def to_s
    slug
  end

end
