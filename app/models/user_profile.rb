class UserProfile < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true
  validates :last_name, presence: true
  has_one_attached :avatar
  delegate :email_address, to: :user
  has_one :calendar, through: :user, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end
end
