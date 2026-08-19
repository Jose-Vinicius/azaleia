class AiController < ApplicationController
  def index
    @active_goals = Current.user.goals.active.order(:title)
  end

  def analyze_tasks
    period_days = params[:period_days].presence ? params[:period_days].to_i : 30
    @period_days = period_days
    @analysis_markdown = Ai::TaskAnalysisService.call(Current.user, period_days: period_days)
    
    respond_to do |format|
      format.turbo_stream { render :analyze_tasks }
      format.html { render :index }
    end
  rescue StandardError => e
    flash.now[:alert] = "Erro na Análise de IA: #{e.message}"
    @period_days = params[:period_days] || 30
    @active_goals = Current.user.goals.active.order(:title)
    respond_to do |format|
      format.turbo_stream { render :analyze_tasks, status: :unprocessable_entity }
      format.html { render :index, status: :unprocessable_entity }
    end
  end

  def suggest_goals
    @suggested_goals = Ai::GoalSuggestionService.suggest_goals(Current.user)
    @active_goals = Current.user.goals.active.order(:title)

    respond_to do |format|
      format.turbo_stream { render :suggest_goals }
      format.html { render :index }
    end
  rescue StandardError => e
    flash.now[:alert] = "Erro ao sugerir metas: #{e.message}"
    @active_goals = Current.user.goals.active.order(:title)
    respond_to do |format|
      format.turbo_stream { render :suggest_goals, status: :unprocessable_entity }
      format.html { render :index, status: :unprocessable_entity }
    end
  end

  def generate_smart_fields
    title = params[:title].to_s.strip
    description = params[:description].to_s.strip

    if title.blank?
      render json: { error: "Por favor, preencha o título da meta antes de solicitar o preenchimento por IA." }, status: :bad_request
      return
    end

    smart_fields = Ai::GoalSuggestionService.generate_smart_fields(Current.user, title: title, description: description)
    render json: smart_fields
  rescue StandardError => e
    render json: { error: "Erro ao gerar campos SMART: #{e.message}" }, status: :internal_server_error
  end

  def accept_goal
    goal_params = params.require(:goal).permit(
      :title, :description, :smart_specific, :smart_measurable,
      :smart_achievable, :smart_relevant, :smart_timebound,
      :psychometric_focus, :target_date
    )

    @goal = Current.user.goals.build(goal_params)
    @goal.status = :active

    if @goal.save
      redirect_to goals_path, notice: "Meta SMART '#{@goal.title}' adicionada com sucesso!"
    else
      redirect_to ai_dashboard_path, alert: "Não foi possível adicionar a meta: #{@goal.errors.full_messages.join(', ')}"
    end
  end

  def decompose_goal
    goal = Current.user.goals.find(params[:goal_id])
    created_tasks = Ai::GoalDecomposerService.call(Current.user, goal, create_tasks: true)

    redirect_to goal_path(goal), notice: "#{created_tasks.count} tarefas geradas e adicionadas à meta '#{goal.title}'!"
  rescue StandardError => e
    redirect_to ai_dashboard_path, alert: "Erro ao decompor meta: #{e.message}"
  end

  def decompose_okr
    okr = Current.user.okrs.find(params[:okr_id])
    created_tasks = Ai::OkrDecomposerService.call(Current.user, okr, create_tasks: true)

    redirect_to okrs_path, notice: "#{created_tasks.count} tarefas geradas por IA para o OKR '#{okr.title}'!"
  rescue StandardError => e
    redirect_to okrs_path, alert: "Erro ao sugerir tarefas por IA: #{e.message}"
  end

  def decompose_key_result
    key_result = KeyResult.joins(:okr).where(okrs: { user_id: Current.user.id }).find(params[:key_result_id])
    created_tasks = Ai::OkrDecomposerService.call(Current.user, key_result, create_tasks: true)

    redirect_to okrs_path, notice: "#{created_tasks.count} tarefas geradas por IA para o Resultado-Chave!"
  rescue StandardError => e
    redirect_to okrs_path, alert: "Erro ao sugerir tarefas por IA para o Resultado-Chave: #{e.message}"
  end

  def schedule_open_tasks
    @schedule_result = Ai::OpenTasksSchedulerService.suggest(Current.user)
    task_ids = (@schedule_result["suggestions"] || []).map { |s| s["task_id"] }
    @open_tasks = Current.user.tasks.where(id: task_ids).includes(:multiplier, :project, :goal).index_by(&:id)
    @active_goals = Current.user.goals.active.order(:title)

    respond_to do |format|
      format.turbo_stream { render :schedule_open_tasks }
      format.html { render :index }
    end
  rescue StandardError => e
    flash.now[:alert] = "Erro ao sugerir agendamento com IA: #{e.message}"
    @active_goals = Current.user.goals.active.order(:title)
    respond_to do |format|
      format.turbo_stream { render :schedule_open_tasks, status: :unprocessable_entity }
      format.html { render :index, status: :unprocessable_entity }
    end
  end

  def apply_open_tasks_schedule
    schedule_params = params[:schedule]
    updated_count = Ai::OpenTasksSchedulerService.apply_schedules(Current.user, schedule_params)
    @active_goals = Current.user.goals.active.order(:title)

    if updated_count > 0
      flash.now[:notice] = "#{updated_count} tarefas agendadas com sucesso baseadas na análise da IA!"
    else
      flash.now[:alert] = "Nenhuma tarefa foi selecionada para agendamento."
    end

    respond_to do |format|
      format.turbo_stream { render :apply_open_tasks_schedule }
      format.html { redirect_to ai_dashboard_path, notice: flash[:notice] || flash[:alert] }
    end
  rescue StandardError => e
    flash.now[:alert] = "Erro ao aplicar agendamentos: #{e.message}"
    @active_goals = Current.user.goals.active.order(:title)
    respond_to do |format|
      format.turbo_stream { render :apply_open_tasks_schedule, status: :unprocessable_entity }
      format.html { redirect_to ai_dashboard_path, alert: e.message }
    end
  end

  def logs
    @logs = Current.user.ai_request_logs.recent.limit(50)
  end

  def show_log
    @log = Current.user.ai_request_logs.find(params[:id])
  end

  def clear_logs
    Current.user.ai_request_logs.destroy_all
    redirect_to ai_dashboard_path, notice: "Histórico de logs de IA limpo com sucesso!"
  end
end
