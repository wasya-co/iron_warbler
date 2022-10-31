
class IronWarbler::OptionWatch < ActiveRecord::Base
  self.table_name = 'option_watches'

  validates :ticker, presence: true # like NVDA
  ## symbol is # like NVDA_021822C230
  validates :strike, presence: true
  CONTRACT_TYPES = [ :PUT, :CALL ]
  validates :contractType, presence: true
  validates :date, presence: true

  NOTIFICATION_TYPES = [ :NONE, :EMAIL, :SMS ]
  ACTIONS            = NOTIFICATION_TYPES

  DIRECTIONS      = [ :ABOVE, :BELOW ]

  def action
    notificationType
  end

  ## @TODO: validate uniqueness of these based on all the fields. _vp_ 2022-10-31

  ## @TODO: this should exclude the ones marked inactive, and the ones in the past.
  def self.active
    self.all.to_a
  end

end

