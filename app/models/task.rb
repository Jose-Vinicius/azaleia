class Task < ApplicationRecord
  validates :title, presence: true

  has_many :time_entries, dependent: :destroy
  belongs_to :multiplier, optional: true

  def priority
    return 1 unless estimated_minutes.present? && estimated_minutes > 0
    (estimated_minutes.to_f / 60.0).ceil
  end

  def score
    multiplier_val = multiplier ? multiplier.value : 1.0
    priority * multiplier_val
  end

  def self.get_scheduled_tasks
    tasks = Task.includes(:multiplier).where.not(schedule_at: nil).where(completed: [ nil ]).order(schedule_at: :asc)
    tasks.group_by { |task| task.schedule_at.to_date }.transform_values { |day_tasks| day_tasks.sort_by { |t| -t.score } }
  end

  def self.get_schedule_tasks
    Task.includes(:multiplier).where(schedule_at: nil).where(completed: [ nil ]).sort_by { |t| -t.score }
  end

  def self.get_completed_tasks
    Task.where(completed: true)
  end

  def self.get_uncompleted_tasks
    Task.where(completed: false)
  end
end
