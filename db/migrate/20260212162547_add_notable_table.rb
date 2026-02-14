class AddNotableTable < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.references :notable, polymorphic: true, null: false
      t.text :body, null: false
      t.timestamps
    end
  end
end
