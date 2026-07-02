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

    respond_to do |format|
      if @note.save
        format.turbo_stream
        format.html { redirect_to notes_path, notice: "Anotação criada com sucesso." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @note.update(note_params)
        format.turbo_stream
        format.html { redirect_to notes_path, notice: "Anotação atualizada com sucesso." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @note.destroy
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notes_path, notice: "Anotação excluída com sucesso." }
    end
  end

  private

    def set_note
      @note = Current.user.notes.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:title, :description)
    end
end
