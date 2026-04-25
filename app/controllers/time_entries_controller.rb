class TimeEntriesController < ApplicationController
  def create
    @task = Current.user.tasks.find(params.expect(:task_id))
    @time_entry = @task.time_entries.build(time_entry_params)

    respond_to do |format|
      if @time_entry.save
        format.turbo_stream
        format.html { redirect_to @task, notice: "Progresso atualizado com sucesso." }
      else
        format.html { redirect_to @task, alert: "Erro ao atualizar progresso." }
      end
    end
  end

  def destroy
    @task = Current.user.tasks.find(params.expect(:task_id))
    @time_entry = @task.time_entries.find(params.expect(:id))
    @time_entry.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @task, notice: "Registro removido com sucesso." }
    end
  end

  private

  def time_entry_params
    params.expect(time_entry: [ :duration_minutes, :notes ])
  end
end
