class Task < ApplicationRecord
  STATUSES = %w[pending doing done].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  RECURRENCE_OPTIONS = %w[none daily weekly monthly].freeze

  belongs_to :user
  belongs_to :project, optional: true
  belongs_to :goal, optional: true
  belongs_to :key_result, optional: true
  has_many :time_entries, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :task_integration, dependent: :destroy
  belongs_to :multiplier, optional: true
  has_many_attached :images

  validates :recurrence, inclusion: { in: RECURRENCE_OPTIONS }, allow_blank: true, if: -> { respond_to?(:recurrence) }

  attr_accessor :sync_to_google

  before_save :set_completed_at, if: :completed_changed?
  before_save :sync_status_with_completed, if: :status_changed?
  before_save :clear_notifications, if: :schedule_at_changed?
  after_save :handle_recurrence_on_completion, if: -> { saved_change_to_completed?(to: true) }
  after_commit :enqueue_google_sync, on: [ :create, :update ]
  before_destroy :enqueue_google_delete

  def priority
    return 1 unless estimated_minutes.present? && estimated_minutes > 0
    (estimated_minutes.to_f / 60.0).ceil
  end

  def score
    multiplier_val = multiplier ? multiplier.value : 1.0
    priority * multiplier_val
  end

  def self.get_scheduled_tasks(user, include_completed: false, filter_period: nil)
    tasks = user.tasks.includes(:multiplier, :project).where.not(schedule_at: nil)
    tasks = tasks.where(completed: [ nil ]) unless include_completed

    if filter_period.present?
      case filter_period.to_s.downcase
      when "week"
        tasks = tasks.where(schedule_at: Time.current.beginning_of_week..Time.current.end_of_week)
      when "month"
        tasks = tasks.where(schedule_at: Time.current.beginning_of_month..Time.current.end_of_month)
      when "year"
        tasks = tasks.where(schedule_at: Time.current.beginning_of_year..Time.current.end_of_year)
      end
    end

    tasks = tasks.order(schedule_at: :asc)
    tasks.group_by { |task| task.schedule_at.to_date }.transform_values { |day_tasks| day_tasks.sort_by { |t| t.completed.nil? ? 0 : 1 }.then { |sorted| sorted.sort_by { |t| t.completed.nil? ? -t.score : 0 } } }
  end

  def self.get_schedule_tasks(user)
    user.tasks.includes(:multiplier, :project).where(schedule_at: nil).where(completed: [ nil ]).sort_by { |t| -t.score }
  end

  def self.get_completed_tasks(user)
    user.tasks.where(completed: true)
  end

  def self.get_uncompleted_tasks(user)
    user.tasks.where(completed: false)
  end

  def self.get_history_tasks(user)
    user.tasks.includes(:multiplier, :project).where.not(completed: nil).order(completed_at: :desc)
  end

  private

  def clear_notifications
    notifications.destroy_all
  end

  def sync_status_with_completed
    if status == "done"
      self.completed = true
    elsif status_was == "done"
      self.completed = nil
    end
  end

  def set_completed_at
    if completed.nil?
      self.completed_at = nil
    else
      self.completed_at = Time.current
    end
  end

  def enqueue_google_sync
    # Only enqueue if the checkbox was present in the form (sync_to_google won't be nil)
    # or if we need to clean it up because the task was completed
    return if sync_to_google.nil? && completed.nil?

    should_sync = ActiveRecord::Type::Boolean.new.cast(sync_to_google)

    # If the task is completed, we want to remove it from the calendar
    should_sync = false if completed.present?

    SyncTaskWithGoogleJob.perform_later(self.id, should_sync)
  end

  def handle_recurrence_on_completion
    return unless respond_to?(:recurrence)
    rec_val = try(:recurrence)
    return if rec_val.blank? || rec_val == "none"

    base_date = schedule_at.presence || Time.current
    next_date = case rec_val
                when "daily"   then base_date + 1.day
                when "weekly"  then base_date + 1.week
                when "monthly" then base_date + 1.month
                else base_date + 1.day
                end

    new_task_attrs = {
      title: title,
      description: description,
      estimated_minutes: estimated_minutes,
      multiplier_id: multiplier_id,
      project_id: project_id,
      goal_id: goal_id,
      key_result_id: key_result_id,
      schedule_at: next_date,
      status: "pending",
      completed: nil
    }
    new_task_attrs[:recurrence] = rec_val if respond_to?(:recurrence)

    new_task = user.tasks.create!(new_task_attrs)

    if images.attached?
      images.each do |img|
        new_task.images.attach(img.blob)
      end
    end
  end

  def enqueue_google_delete
    if task_integration
      DeleteGoogleCalendarEventJob.perform_later(task_integration.user_integration_id, task_integration.external_id)
    end
  end
end
