json.extract! task, :id, :title, :description, :schedule_at, :created_at, :updated_at
json.url task_url(task, format: :json)
