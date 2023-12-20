
class Iro::Alert < Iro::ApplicationRecord
  self.table_name = 'iro_alerts'

  DIRECTION_ABOVE = 'ABOVE'
  DIRECTION_BELOW = 'BELOW'
  def self.directions_list
    [ nil, DIRECTION_ABOVE, DIRECTION_BELOW ]
  end

end
