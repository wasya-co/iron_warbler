
##
## SQL
##
class Iro::Stock < ApplicationRecord
  self.table_name = 'iro_stocks'

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ 'active', 'inactive' ]

  validates :ticker, uniqueness: true, presence: true

  def self.active
    where( status: STATUS_ACTIVE )
  end

end
