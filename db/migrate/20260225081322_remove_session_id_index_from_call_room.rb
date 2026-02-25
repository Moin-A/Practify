class RemoveSessionIdIndexFromCallRoom < ActiveRecord::Migration[8.0]
  def change
    remove_index :call_rooms, :vonage_session_id
  end
end
