class NotesController < ApplicationController
  before_action :set_note, only: %i[ show edit update destroy ]

  def index
    @notes = Current.user.notes.order(created_at: :desc)
  end

  def show
  end

  def new
    @note = Current.user.notes.build
  end

  def edit
  end

  def create
    @note = Current.user.notes.build(note_params)

    if @note.save
      redirect_to notes_path, notice: "Anotação criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @note.update(note_params)
      redirect_to notes_path, notice: "Anotação atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path, notice: "Anotação excluída com sucesso."
  end

  private

    def set_note
      @note = Current.user.notes.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:title, :description)
    end
end
