class AddWorkScheduleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :work_days, :string, default: "Segunda a Sexta"
    add_column :users, :work_start_time, :string, default: "08:00"
    add_column :users, :work_end_time, :string, default: "18:00"
    add_column :users, :lunch_break, :string, default: "12:00 às 13:00"
    add_column :users, :routine_notes, :text
  end
end
