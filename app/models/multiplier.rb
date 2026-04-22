class Multiplier < ApplicationRecord
  has_many :tasks, dependent: :nullify

  validates :name, presence: true
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 1.0 }
end
