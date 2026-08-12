class GoalsController < ApplicationController
  before_action :set_goal, only: %i[ show edit update destroy ]

  def index
    @goals = Current.user.goals.order(created_at: :desc)
  end

  def show
    @tasks = @goal.tasks.order(created_at: :desc)
  end

  def new
    @goal = Current.user.goals.new
  end

  def edit
  end

  def create
    @goal = Current.user.goals.build(goal_params)

    if @goal.save
      redirect_to goals_path, notice: "Meta criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @goal.update(goal_params)
      redirect_to goal_path(@goal), notice: "Meta atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy!
    redirect_to goals_path, notice: "Meta removida com sucesso."
  end

  private

  def set_goal
    @goal = Current.user.goals.find(params.expect(:id))
  end

  def goal_params
    params.expect(goal: [
      :title, :description, :smart_specific, :smart_measurable,
      :smart_achievable, :smart_relevant, :smart_timebound,
      :status, :target_date, :psychometric_focus
    ])
  end
end
