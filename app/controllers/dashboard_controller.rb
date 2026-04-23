class DashboardController < ApplicationController
  def index
    @cards = Task.get_scheduled_tasks(Current.user)

    respond_to do |format|
      format.html
      format.json { render json: @cards }
    end
  end
end
