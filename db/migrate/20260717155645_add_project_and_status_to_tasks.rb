class AddProjectAndStatusToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :project, null: true, foreign_key: true
    add_column :tasks, :status, :string, default: "pending", null: false
  end
end
