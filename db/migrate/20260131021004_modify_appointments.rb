class ModifyAppointments < ActiveRecord::Migration[8.0]
  def change
    add_reference :appointments, :publisher, foreign_key: { to_table: :users }
    add_reference :appointments, :subscriber, foreign_key: { to_table: :users }
  end
end
