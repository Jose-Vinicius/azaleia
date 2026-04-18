class DashboardController < ApplicationController
  def index
    @cards = Task.get_tasks
  end
end
