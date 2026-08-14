class KeyResultsController < ApplicationController
  before_action :set_okr
  before_action :set_key_result, only: %i[ update destroy ]

  def create
    @key_result = @okr.key_results.build(key_result_params)

    if @key_result.save
      respond_to do |format|
        format.html { redirect_to okrs_path, notice: "Resultado-chave adicionado!" }
        format.turbo_stream
      end
    else
      redirect_to okrs_path, alert: "Erro ao adicionar resultado-chave: #{@key_result.errors.full_messages.join(', ')}"
    end
  end

  def update
    if @key_result.update(key_result_params)
      respond_to do |format|
        format.html { redirect_to okrs_path, notice: "Resultado-chave atualizado!" }
        format.turbo_stream
      end
    else
      redirect_to okrs_path, alert: "Erro ao atualizar resultado-chave."
    end
  end

  def destroy
    @key_result.destroy!
    respond_to do |format|
      format.html { redirect_to okrs_path, notice: "Resultado-chave removido." }
      format.turbo_stream
    end
  end

  private

  def set_okr
    @okr = Current.user.okrs.find(params[:okr_id])
  end

  def set_key_result
    @key_result = @okr.key_results.find(params[:id])
  end

  def key_result_params
    params.require(:key_result).permit(:title)
  end
end
