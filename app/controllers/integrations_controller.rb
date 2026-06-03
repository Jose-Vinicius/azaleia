class IntegrationsController < ApplicationController
  def destroy
    integration = Current.user.user_integrations.find_by!(provider: params[:provider])
    integration.destroy!
    
    redirect_to settings_path, notice: "Integração com #{params[:provider].capitalize} desconectada com sucesso."
  end
end
