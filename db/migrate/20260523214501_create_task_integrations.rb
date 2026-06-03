class CreateTaskIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :task_integrations do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user_integration, null: false, foreign_key: true
      t.string :external_id, null: false

      t.timestamps
    end

    add_index :task_integrations, :external_id, unique: true
  end
end
