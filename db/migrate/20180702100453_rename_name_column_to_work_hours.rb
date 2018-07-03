class RenameNameColumnToWorkHours < ActiveRecord::Migration[5.2]
  def change
    rename_column :work_hours, :name, :project
  end
end
