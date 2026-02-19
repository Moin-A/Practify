class Note < ApplicationRecord
  has_noticed_notifications
  before_destroy :delete_notification
  belongs_to :notable, polymorphic: true
  validates :category, presence: true
  validates :category, inclusion: { in: %w[ note observation ] }

  def delete_notification
   notifications_as_note.destroy_all if notifications_as_note.any?
  end
end
