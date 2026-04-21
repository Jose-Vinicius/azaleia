class CreateTimeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :time_entries do |t|
      t.references :task, null: false, foreign_key: true
      t.integer :duration_minutes, null: false, default: 0

      t.timestamps
    end
  end
end
