
class CreateIroAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :iro_alerts do |t|

      t.string  :class_name
      t.string  :kind
      t.string  :symbol
      t.string  :direction
      t.float   :strike
      t.integer :profile_id

      t.timestamps
    end
  end
end
