
class Iro::Alert < Iro::ApplicationRecord
  self.table_name = 'iro_alerts'


  DIRECTION_ABOVE = 'ABOVE'
  DIRECTION_BELOW = 'BELOW'
  def self.directions_list
    [ nil, DIRECTION_ABOVE, DIRECTION_BELOW ]
  end

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ 'active', 'inactive' ]


  def self.active
    where( status: STATUS_ACTIVE )
  end


end
