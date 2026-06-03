class OmniauthCallbacksController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    provider = auth.provider
    uid = auth.uid
    credentials = auth.credentials

    # Find or create integration for current user
    integration = Current.user.user_integrations.find_or_initialize_by(provider: provider)

    integration.update!(
      uid: uid,
      access_token: credentials.token,
      refresh_token: credentials.refresh_token || integration.refresh_token,
      expires_at: Time.at(credentials.expires_at)
    )

    redirect_to root_path, notice: "Integração com #{provider.capitalize} concluída com sucesso."
  end

  def failure
    redirect_to root_path, alert: "Falha na integração: #{params[:message]}"
  end
end
