class CreateCalendars < ActiveRecord::Migration[8.0]
  def change
    create_table :calendars do |t|
      t.string :name, null: false
      t.string :timezone, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :calendars, :user_id unless index_exists?(:calendars, :user_id)
  end
end
