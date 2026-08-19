class AiRequestLog < ApplicationRecord
  belongs_to :user

  validates :action_name, presence: true
  validates :status, inclusion: { in: %w[success error] }

  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: "success") }
  scope :failed, -> { where(status: "error") }

  def success?
    status == "success"
  end
end
