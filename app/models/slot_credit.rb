class SlotCredit < ApplicationRecord
  belongs_to :slot
  enum :package, { starter: 0, standard: 1, bundle: 2 }
  validates :package, presence: true
end
