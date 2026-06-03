class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :backfill_notifications, if: -> { request.format.html? }

  private

  def backfill_notifications
    return unless Current.user

    missed_tasks = Current.user.tasks
                          .where(completed: nil)
                          .where.not(schedule_at: nil)
                          .where("schedule_at <= ?", Time.current)

    missed_tasks.find_each do |task|
      existing_notifications = Current.user.notifications.where(task: task).to_a

      if existing_notifications.empty?
        notification = Current.user.notifications.build(task: task)
      else
        notification = existing_notifications.shift
        # Destroy any duplicates created by previous race conditions
        existing_notifications.each(&:destroy)
      end

      formatted_time = task.schedule_at.strftime("%d/%m/%Y às %H:%M")
      notification.update!(
        message: "Sua tarefa \"#{task.title}\" passou do horário agendado (#{formatted_time})."
      )
    end
  end
end
