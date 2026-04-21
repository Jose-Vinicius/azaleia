class TimeEntry < ApplicationRecord
  belongs_to :task

  validates :duration_minutes, numericality: { greater_than: 0 }
end
