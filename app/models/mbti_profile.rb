class MbtiProfile < ApplicationRecord
  belongs_to :user

  validates :final_type, presence: true
end
