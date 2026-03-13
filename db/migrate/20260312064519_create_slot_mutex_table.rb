class CreateSlotMutexTable < ActiveRecord::Migration[8.0]
  def change
    create_table :slot_mutexes do |t|
      t.references :slot, index: { unique: true }
      t.references :user, :held_by_user, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :slot_mutexes, :slot_id, unique: true unless index_exists?(:slot_mutexes, :slot_id, unique: true)
  end
end
