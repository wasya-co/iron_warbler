class AddAlertStatus < ActiveRecord::Migration[6.1]
  def change
    add_column :iro_alerts, :status, :string, null: false, index: true, default: 'active'
  end
end
