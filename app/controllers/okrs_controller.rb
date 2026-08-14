class OkrsController < ApplicationController
  before_action :set_okr, only: %i[ show edit update destroy ]

  def index
    @okrs = Current.user.okrs.includes(key_results: :tasks).order(created_at: :desc)
  end

  def show
    @key_results = @okr.key_results.includes(:tasks)
  end

  def new
    @okr = Current.user.okrs.new(quarter: "Q3 2026")
  end

  def edit
  end

  def create
    @okr = Current.user.okrs.build(okr_params)

    if @okr.save
      redirect_to okrs_path, notice: "OKR '#{@okr.title}' criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @okr.update(okr_params)
      redirect_to okrs_path, notice: "OKR '#{@okr.title}' atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    title = @okr.title
    @okr.destroy!
    redirect_to okrs_path, notice: "OKR '#{title}' removido com sucesso."
  end

  private

  def set_okr
    @okr = Current.user.okrs.find(params[:id])
  end

  def okr_params
    params.require(:okr).permit(:title, :description, :quarter, :status)
  end
end
