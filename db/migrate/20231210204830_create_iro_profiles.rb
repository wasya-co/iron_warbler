class CreateIroProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :iro_profiles do |t|

      t.string  :email
      t.string  :role_name
      t.integer :user_id

      t.timestamps
    end
  end
end
