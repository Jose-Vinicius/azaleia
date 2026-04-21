class AddEstimatedminutesToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :estimated_minutes, :integer, default: 0
  end
end
