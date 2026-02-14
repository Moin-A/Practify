class Notes < ApplicationRecord
  belongs_to :notable, polymorphic: true
  validates :category, presence: true
  validates :category, inclusion: { in: %w[ note observation ] }
end