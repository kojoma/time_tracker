class AddUniqueIndexToWorkHour < ActiveRecord::Migration[5.2]
  def change
    add_index :work_hours, [:project, :date], unique: true
  end
end
