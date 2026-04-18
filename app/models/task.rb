class Task < ApplicationRecord
  def self.get_tasks
    where.not(schedule_at: nil).order(schedule_at: :asc).group_by { |task| task.schedule_at.to_date }
  end
end
