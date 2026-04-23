class HistoryController < ApplicationController
  def index
    @tasks = Task.get_history_tasks(Current.user)
  end
end
