class RenameModelNameInAiRequestLogs < ActiveRecord::Migration[8.1]
  def up
    if column_exists?(:ai_request_logs, :model_name)
      rename_column :ai_request_logs, :model_name, :ai_model
    end
  end

  def down
    if column_exists?(:ai_request_logs, :ai_model) && !column_exists?(:ai_request_logs, :model_name)
      rename_column :ai_request_logs, :ai_model, :model_name
    end
  end
end
