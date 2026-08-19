class SettingsController < ApplicationController
  def index
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Horários de trabalho e rotina salvos com sucesso!" }
        format.html { redirect_to settings_path, notice: "Configurações salvas com sucesso!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:alert] = "Erro ao salvar configurações: #{@user.errors.full_messages.join(', ')}" }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:work_days, :work_start_time, :work_end_time, :lunch_break, :routine_notes)
  end
end
