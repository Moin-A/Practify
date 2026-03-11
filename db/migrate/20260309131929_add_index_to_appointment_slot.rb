class AddIndexToAppointmentSlot < ActiveRecord::Migration[8.0]
  def change
    add_index :appointments, :slot_id unless index_exists?(:appointments, :slot_id)
  end
end
