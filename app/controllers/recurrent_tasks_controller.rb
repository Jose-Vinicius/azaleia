class RecurrentTasksController < ApplicationController
  def index
    if Task.column_names.include?("recurrence")
      @recurrent_tasks = Current.user.tasks.includes(:multiplier, :project).where.not(recurrence: "none").order(created_at: :desc)
      @grouped_tasks = @recurrent_tasks.group_by { |t| t.try(:recurrence) }
    else
      @recurrent_tasks = Task.none
      @grouped_tasks = {}
    end
  end
end
