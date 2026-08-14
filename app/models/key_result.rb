class KeyResult < ApplicationRecord
  belongs_to :okr
  has_many :tasks, dependent: :nullify

  validates :title, presence: true

  def progress_percentage
    total = tasks.count
    return 0 if total.zero?

    completed = tasks.where(completed: true).count
    ((completed.to_f / total) * 100).round
  end
end
