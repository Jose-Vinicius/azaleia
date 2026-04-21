class DashboardController < ApplicationController
  def index
    @cards = Task.get_scheduled_tasks

    respond_to do |format|
      format.html
      format.json { render json: @cards }
    end
  end
end
