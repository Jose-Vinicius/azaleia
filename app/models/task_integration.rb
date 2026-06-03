class TaskIntegration < ApplicationRecord
  belongs_to :task
  belongs_to :user_integration

  validates :external_id, presence: true
end
