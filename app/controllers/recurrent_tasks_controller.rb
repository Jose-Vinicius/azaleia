class RecurrentTasksController < ApplicationController
  def index
    @recurrent_tasks = Current.user.tasks.includes(:multiplier, :project).where.not(recurrence: "none").order(created_at: :desc)
    @grouped_tasks = @recurrent_tasks.group_by(&:recurrence)
  end
end
