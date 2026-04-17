class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.timestamp :schedule_at

      t.timestamps
    end
  end
end
