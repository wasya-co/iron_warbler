
class PriceActionItemInterval < ActiveRecord::Migration[6.0]
  def change

    add_column :option_price_items, :interval, :string

  end
end
