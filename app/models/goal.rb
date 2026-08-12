class Goal < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :nullify

  enum :status, { draft: 0, active: 1, paused: 2, completed: 3 }, default: :active

  validates :title, presence: true
end
