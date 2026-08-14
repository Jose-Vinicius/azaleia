class Okr < ApplicationRecord
  belongs_to :user
  has_many :key_results, dependent: :destroy

  enum :status, { draft: 0, active: 1, paused: 2, completed: 3, archived: 4 }, default: :active

  validates :title, :quarter, presence: true

  def progress_percentage
    return 0 if key_results.empty?
    (key_results.sum(&:progress_percentage).to_f / key_results.size).round
  end
end
