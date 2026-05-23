class NotificationsController < ApplicationController
  def index
    @notifications = Current.user.notifications.unread.recent.limit(20)
    render layout: false
  end

  def create
    @task = Current.user.tasks.find_by(id: params[:task_id])
    
    # Avoid creating multiple notifications for the same task
    @notification = Current.user.notifications.find_or_initialize_by(
      task: @task
    )
    
    @notification.message = params[:message]
    @notification.read_at = nil if @notification.persisted?
    @notification.save!

    @notifications = Current.user.notifications.unread.recent.limit(20)

    respond_to do |format|
      format.turbo_stream { render :create }
      format.json { head :ok }
    end
  end

  def update
    @notification = Current.user.notifications.find(params[:id])
    @notification.update(read_at: Time.current)
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to request.referer || root_path }
    end
  end

  def mark_all_as_read
    Current.user.notifications.unread.update_all(read_at: Time.current)
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to request.referer || root_path }
    end
  end
end
