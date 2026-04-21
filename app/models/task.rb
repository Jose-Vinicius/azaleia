class Task < ApplicationRecord
  validates :title, presence: true

  def self.get_scheduled_tasks
    where.not(schedule_at: nil).order(schedule_at: :asc).group_by { |task| task.schedule_at.to_date }
  end

  def self.get_schedule_tasks
    where(schedule_at: nil)
  end
end
