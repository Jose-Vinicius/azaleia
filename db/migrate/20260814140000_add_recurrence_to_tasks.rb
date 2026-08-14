class AddRecurrenceToTasks < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:tasks, :recurrence)
      add_column :tasks, :recurrence, :string, default: "none", null: false
    end
  end
end
