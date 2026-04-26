class MetricsController < ApplicationController
  def index
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    # Ensure end_date is after start_date
    if @end_date < @start_date
      @end_date = @start_date
    end

    # Time entries logic (Time spent)
    @total_minutes = TimeEntry.joins(:task)
                              .where(tasks: { user_id: Current.user.id })
                              .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                              .sum(:duration_minutes)

    # Task totals
    @total_inbox = Current.user.tasks.where(schedule_at: nil, completed: nil).count
    @total_scheduled = Current.user.tasks.where(schedule_at: @start_date.beginning_of_day..@end_date.end_of_day, completed: nil).count
    @total_completed = Current.user.tasks.where(completed: true, completed_at: @start_date.beginning_of_day..@end_date.end_of_day).count
    @total_discarded = Current.user.tasks.where(completed: false, completed_at: @start_date.beginning_of_day..@end_date.end_of_day).count

    # Heatmap data (Productivity Score per day and Task Count)
    completed_tasks = Current.user.tasks.includes(:multiplier).where(completed: true, completed_at: @start_date.beginning_of_day..@end_date.end_of_day)
    @heatmap_data = Hash.new { |h, k| h[k] = { score: 0, count: 0 } }
    completed_tasks.each do |task|
      date_key = task.completed_at.to_date.to_s
      @heatmap_data[date_key][:score] += task.score
      @heatmap_data[date_key][:count] += 1
    end

    # Top 5 Tasks by Time Spent
    @top_tasks = Task.joins(:time_entries)
                     .where(user_id: Current.user.id)
                     .where(time_entries: { created_at: @start_date.beginning_of_day..@end_date.end_of_day })
                     .group("tasks.id")
                     .select("tasks.*, SUM(time_entries.duration_minutes) as period_duration")
                     .order("period_duration DESC")
                     .limit(5)

    # Load multipliers to avoid N+1 if we iterate top_tasks
    ActiveRecord::Associations::Preloader.new(records: @top_tasks, associations: :multiplier).call
  end
end
