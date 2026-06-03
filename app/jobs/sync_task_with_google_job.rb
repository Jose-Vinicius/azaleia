class SyncTaskWithGoogleJob < ApplicationJob
  queue_as :default

  def perform(task_id, should_sync)
    task = Task.find_by(id: task_id)
    return unless task

    user_integration = task.user.user_integrations.find_by(provider: 'google_oauth2')
    return unless user_integration

    service = GoogleCalendarService.new(user_integration)

    if should_sync && task.schedule_at.present? && task.completed.nil?
      service.sync_task(task)
    else
      service.delete_task(task) if task.task_integration
    end
  end
end
