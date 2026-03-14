class AddTypeToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :type, :string
    add_index :notes, :type
  end
end
