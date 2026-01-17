class Calendar < ApplicationRecord
  belongs_to :user
  has_many :slots, dependent: :destroy

  validates :name, presence: true
  validates :timezone, presence: true
  validates :user_id, presence: true
end
