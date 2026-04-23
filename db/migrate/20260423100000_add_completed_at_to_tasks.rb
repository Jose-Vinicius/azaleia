class AddCompletedAtToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :completed_at, :datetime, null: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE tasks SET completed_at = updated_at WHERE completed IS NOT NULL
        SQL
      end
    end
  end
end
