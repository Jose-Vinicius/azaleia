class Task < ApplicationRecord
  validates :title, presence: true
  
  has_many :time_entries, dependent: :destroy

  def self.get_scheduled_tasks
    Task.where.not(schedule_at: nil).where(completed: [ nil ]).order(schedule_at: :asc).group_by { |task| task.schedule_at.to_date }
  end

  def self.get_schedule_tasks
    Task.where(schedule_at: nil).where(completed: [ nil ])
  end

  def self.get_completed_tasks
    Task.where(completed: true)
  end

  def self.get_uncompleted_tasks
    Task.where(completed: false)
  end
end
