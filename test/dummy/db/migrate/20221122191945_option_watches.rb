class OptionWatches < ActiveRecord::Migration[6.1]
  def change

    create_table :iwa_option_watches do |t|

      t.column :ticker, :string
      t.column :symbol, :string
      t.column :description, :string
      t.column :strike, :float
      t.column :contractType, :string
      t.column :date, :date
      t.column :direction, :string
      t.column :notificationType, :string
      t.column :email, :string
      t.column :phone, :string
      t.column :profile_id, :string

    end

  end
end
