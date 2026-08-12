class PsychometricsController < ApplicationController
  def show
    @eqi_profile = Current.user.eqi_profile
    @mbti_profile = Current.user.mbti_profile
  end

  def import_eqi
    if params[:file].present?
      json_content = params[:file].read
      Psychometrics::EqiImporterService.call(Current.user, json_content)
      redirect_to psychometrics_path, notice: "Relatório EQ-i 2.0 (Ametista) importado com sucesso!"
    elsif params[:json_data].present?
      Psychometrics::EqiImporterService.call(Current.user, params[:json_data])
      redirect_to psychometrics_path, notice: "Relatório EQ-i 2.0 (Ametista) importado com sucesso!"
    else
      redirect_to psychometrics_path, alert: "Nenhum arquivo ou JSON fornecido."
    end
  rescue StandardError => e
    redirect_to psychometrics_path, alert: "Erro ao importar EQ-i: #{e.message}"
  end

  def import_mbti
    if params[:file].present?
      json_content = params[:file].read
      Psychometrics::MbtiImporterService.call(Current.user, json_content)
      redirect_to psychometrics_path, notice: "Relatório MBTI (Bismuto) importado com sucesso!"
    elsif params[:json_data].present?
      Psychometrics::MbtiImporterService.call(Current.user, params[:json_data])
      redirect_to psychometrics_path, notice: "Relatório MBTI (Bismuto) importado com sucesso!"
    else
      redirect_to psychometrics_path, alert: "Nenhum arquivo ou JSON fornecido."
    end
  rescue StandardError => e
    redirect_to psychometrics_path, alert: "Erro ao importar MBTI: #{e.message}"
  end
end
