class CreateWorkHours < ActiveRecord::Migration[5.2]
  def change
    create_table :work_hours do |t|
      t.string :name
      t.date :date
      t.float :hour

      t.timestamps
    end
  end
end
