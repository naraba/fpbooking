class AddNullConstraintsToSlots < ActiveRecord::Migration[5.1]
  def change
    change_column :slots, :fp_id, :integer, :limit => 8, null: false
    change_column :slots, :start_time, :datetime, null: false
    change_column :slots, :end_time, :datetime, null: false
  end
end
