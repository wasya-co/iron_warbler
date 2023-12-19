class CreateDatapoint < ActiveRecord::Migration[6.1]
  def change

    create_table :iro_datapoints do |t|

      t.string :k, index: true, null: false
      t.float  :v, null: false
      t.date   :d, index: true

      t.timestamps

    end

  end
end
