class DeleteGoogleCalendarEventJob < ApplicationJob
  queue_as :default

  def perform(user_integration_id, external_id)
    user_integration = UserIntegration.find_by(id: user_integration_id)
    return unless user_integration

    service = GoogleCalendarService.new(user_integration)
    service.delete_event(external_id)
  end
end
