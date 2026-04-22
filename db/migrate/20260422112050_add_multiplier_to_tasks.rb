class AddMultiplierToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :multiplier, null: false, foreign_key: true
  end
end
