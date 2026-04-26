class ChangeMultiplierIdNullOnTasks < ActiveRecord::Migration[8.1]
  def change
    change_column_null :tasks, :multiplier_id, true
  end
end
