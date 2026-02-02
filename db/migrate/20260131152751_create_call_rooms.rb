class CreateCallRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :call_rooms do |t|
      t.string :name, null: false
      t.string :vonage_session_id
      t.references :appointment, null: false, foreign_key: true

      t.timestamps
    end

    add_index :call_rooms, :vonage_session_id, unique: true
  end
end
