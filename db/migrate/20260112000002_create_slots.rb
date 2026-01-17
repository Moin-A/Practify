class CreateSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :slots do |t|
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.integer :status, default: 0, null: false
      t.references :calendar, null: false, foreign_key: true

      t.timestamps
    end

    add_index :slots, :calendar_id unless index_exists?(:slots, :calendar_id)
    add_index :slots, :status unless index_exists?(:slots, :status)
    add_index :slots, [ :start_at, :end_at ] unless index_exists?(:slots, [ :start_at, :end_at ])
  end
end
