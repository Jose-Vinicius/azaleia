class CreateAiRequestLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_request_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action_name, null: false
      t.string :ai_model, default: "gemini-2.5-flash"
      t.text :prompt
      t.text :system_instruction
      t.text :response_body
      t.string :status, default: "success", null: false
      t.text :error_message
      t.integer :duration_ms
      t.integer :prompt_tokens
      t.integer :completion_tokens
      t.integer :total_tokens

      t.timestamps
    end

    add_index :ai_request_logs, [ :user_id, :created_at ]
  end
end
