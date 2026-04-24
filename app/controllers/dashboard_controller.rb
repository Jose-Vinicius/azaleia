class DashboardController < ApplicationController
  def index
    @cards = Task.get_scheduled_tasks(Current.user, include_completed: true)

    respond_to do |format|
      format.html
      format.json { render json: @cards }
    end
  end
end
