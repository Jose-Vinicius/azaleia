class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ edit update destroy ]

  def index
    @projects = Current.user.projects.order(:name)
    @current_project = if params[:project_id].present?
      Current.user.projects.find_by(id: params[:project_id])
    else
      @projects.first
    end

    if @current_project
      @tasks_by_status = Task::STATUSES.index_with do |status|
        @current_project.tasks.includes(:multiplier).where(status: status).order(created_at: :desc)
      end
    else
      @tasks_by_status = Task::STATUSES.index_with { |_| [] }
    end
  end

  def new
    @project = Current.user.projects.new
  end

  def create
    @project = Current.user.projects.build(project_params)

    respond_to do |format|
      if @project.save
        format.turbo_stream
        format.html { redirect_to projects_path(project_id: @project.id), notice: "Projeto criado com sucesso." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.turbo_stream
        format.html { redirect_to projects_path(project_id: @project.id), notice: "Projeto atualizado." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to projects_path, notice: "Projeto excluído.", status: :see_other }
    end
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:id])
  end

  def project_params
    params.expect(project: [ :name, :description, :color ])
  end
end
