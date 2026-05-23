class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :task

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def unread?
    read_at.nil?
  end
end
