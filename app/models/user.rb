class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :user_integrations, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :okrs, dependent: :destroy
  has_one :eqi_profile, dependent: :destroy
  has_one :mbti_profile, dependent: :destroy
  has_many :ai_request_logs, dependent: :destroy

  def low_eqi_subscales
    return [] unless eqi_profile

    eqi_profile.attributes.select { |k, v| k.end_with?("_score") && v.present? && v < 85 }.keys
  end

  def work_schedule_summary
    days = work_days.presence || "Segunda a Sexta"
    start_t = work_start_time.presence || "08:00"
    end_t = work_end_time.presence || "18:00"
    lunch = lunch_break.presence || "12:00 às 13:00"
    notes = routine_notes.presence || "Sem observações adicionais de rotina."

    "Jornada: #{days}, das #{start_t} às #{end_t} (Almoço/Pausa: #{lunch}). Rotina/Atividades: #{notes}"
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }
end
