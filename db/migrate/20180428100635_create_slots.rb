class CreateSlots < ActiveRecord::Migration[5.1]
  def change
    create_table :slots do |t|
      t.datetime :start
      t.datetime :end
      t.references :fp, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :slots, [:fp_id, :start]
    add_index :slots, [:user_id, :start]
  end
end
