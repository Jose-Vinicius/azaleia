require 'google/apis/calendar_v3'

class GoogleCalendarService
  def initialize(user_integration)
    @integration = user_integration
    @client = Google::Apis::CalendarV3::CalendarService.new
    @client.authorization = fetch_authorization
  end

  def sync_task(task)
    return unless task.schedule_at

    event = build_event(task)
    task_integration = task.task_integration

    if task_integration
      # Update existing event
      begin
        @client.update_event('primary', task_integration.external_id, event)
      rescue Google::Apis::ClientError => e
        if e.status_code == 404
          # Event was deleted on Google Calendar directly, recreate it
          result = @client.insert_event('primary', event)
          task_integration.update!(external_id: result.id)
        else
          raise e
        end
      end
    else
      # Create new event
      result = @client.insert_event('primary', event)
      TaskIntegration.create!(
        task: task,
        user_integration: @integration,
        external_id: result.id
      )
    end
  end

  def delete_task(task)
    task_integration = task.task_integration
    return unless task_integration

    begin
      @client.delete_event('primary', task_integration.external_id)
    rescue Google::Apis::ClientError => e
      # Ignore if it's already deleted
      raise e unless e.status_code == 404
    ensure
      task_integration.destroy!
    end
  end

  def delete_event(external_id)
    begin
      @client.delete_event('primary', external_id)
    rescue Google::Apis::ClientError => e
      raise e unless e.status_code == 404
    end
  end

  private

  def build_event(task)
    # Azaleia tasks have an estimated duration in minutes, default to 60 if missing
    duration_minutes = task.estimated_minutes.present? && task.estimated_minutes > 0 ? task.estimated_minutes : 60
    end_time = task.schedule_at + duration_minutes.minutes

    Google::Apis::CalendarV3::Event.new(
      summary: "Tarefa: #{task.title}",
      description: task.description,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: task.schedule_at.to_datetime.rfc3339,
        time_zone: Time.zone.name
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: end_time.to_datetime.rfc3339,
        time_zone: Time.zone.name
      )
    )
  end

  def fetch_authorization
    auth = Signet::OAuth2::Client.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      token_credential_uri: 'https://oauth2.googleapis.com/token',
      access_token: @integration.access_token,
      refresh_token: @integration.refresh_token,
      expires_at: @integration.expires_at
    )

    if auth.expired?
      auth.fetch_access_token!
      @integration.update!(
        access_token: auth.access_token,
        refresh_token: auth.refresh_token || @integration.refresh_token,
        expires_at: auth.expires_at
      )
    end

    auth
  end
end
