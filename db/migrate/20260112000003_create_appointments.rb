class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :slot, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end

    add_index :appointments, :user_id unless index_exists?(:appointments, :user_id)
    add_index :appointments, :slot_id, unique: true unless index_exists?(:appointments, :slot_id)
  end
end
