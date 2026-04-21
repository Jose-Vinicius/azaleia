class InboxController < ApplicationController
  def index
    @tasks = Task.get_schedule_tasks
    
    respond_to do |format|
      format.html
      format.json { render json: @tasks }
    end
  end
end
