class DashboardController < ApplicationController
  def index
    @filter_period = params[:filter_period].presence || 'week'
    @cards = Task.get_scheduled_tasks(Current.user, include_completed: true, filter_period: @filter_period)

    respond_to do |format|
      format.html
      format.json { render json: @cards }
    end
  end
end
