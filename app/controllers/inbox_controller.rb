class InboxController < ApplicationController
  def index
    @tasks = Task.get_schedule_tasks
  end
end
