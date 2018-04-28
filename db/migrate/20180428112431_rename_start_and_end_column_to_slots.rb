class RenameStartAndEndColumnToSlots < ActiveRecord::Migration[5.1]
  def change
    rename_column :slots, :start, :start_time
    rename_column :slots, :end, :end_time
  end
end
