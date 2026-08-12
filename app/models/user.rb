class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :user_integrations, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_one :eqi_profile, dependent: :destroy
  has_one :mbti_profile, dependent: :destroy

  def low_eqi_subscales
    return [] unless eqi_profile

    eqi_profile.attributes.select { |k, v| k.end_with?("_score") && v.present? && v < 85 }.keys
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }
end
