class SlotMutex < ApplicationRecord

  belongs_to :held_by_user, class_name: "User", inverse_of: :slot_mutexes
  belongs_to :slot

  scope :expired, -> { where(arel_table[:created_at].lt( Practify::config[:order_mutex_max_age].seconds.ago)) }

  class LockFailed < StandardError; end

  class << self
    def with_lock!(slot)
        raise ArgumentError, "Slot is required" if slot.blank?

        where(slot:, held_by_user: Current.session.user).delete_all

        begin 
          create!(held_by_user: Current.session.user, slot:)  
        rescue ActiveRecord::RecordNotUnique
          error = LockFailed.new("Slot mutex already exists")
          logger.error error.inspect
          raise error
        end 

        yield
        
        ensure
          expired.delete_all 
       end
  end 
end