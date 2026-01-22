class UserProfile < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true
  validates :last_name, presence: true
  has_one_attached :avatar
  has_one :calendar, through: :user, dependent: :destroy
end
