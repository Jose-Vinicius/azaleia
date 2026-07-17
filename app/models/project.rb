class Project < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :nullify

  validates :name, presence: true

  COLORS = %w[#a78bfa #34d399 #f97316 #ef4444 #3b82f6 #eab308 #ec4899 #14b8a6].freeze
end
