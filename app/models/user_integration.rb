class UserIntegration < ApplicationRecord
  belongs_to :user
  has_many :task_integrations, dependent: :destroy

  validates :provider, presence: true
  validates :uid, presence: true
  
  # Helper to check if token is expired
  def expired?
    expires_at.present? && expires_at < Time.current
  end
end
