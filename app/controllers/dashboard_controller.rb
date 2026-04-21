class DashboardController < ApplicationController
  def index
    @cards = Task.get_scheduled_tasks
  end
end
