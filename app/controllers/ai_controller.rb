class AiController < ApplicationController
  def index
    @active_goals = Current.user.goals.active.order(:title)
  end

  def analyze_tasks
    period_days = params[:period_days].presence ? params[:period_days].to_i : 30
    @period_days = period_days
    @analysis_markdown = Ai::TaskAnalysisService.call(Current.user, period_days: period_days)
    
    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  rescue StandardError => e
    flash.now[:alert] = "Erro na Análise de IA: #{e.message}"
    @period_days = params[:period_days] || 30
    @active_goals = Current.user.goals.active.order(:title)
    render :index, status: :unprocessable_entity
  end

  def suggest_goals
    @suggested_goals = Ai::GoalSuggestionService.suggest_goals(Current.user)
    @active_goals = Current.user.goals.active.order(:title)

    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  rescue StandardError => e
    flash.now[:alert] = "Erro ao sugerir metas: #{e.message}"
    @active_goals = Current.user.goals.active.order(:title)
    render :index, status: :unprocessable_entity
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
end
