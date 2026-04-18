class InboxController < ApplicationController
  def index
    @tasks = Task.all
  end
end
