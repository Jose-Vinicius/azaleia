class RenameModelNameInAiRequestLogs < ActiveRecord::Migration[8.1]
  def change
    rename_column :ai_request_logs, :model_name, :ai_model
  end
end
