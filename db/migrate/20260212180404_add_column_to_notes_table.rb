class AddColumnToNotesTable < ActiveRecord::Migration[8.0]
  def up
    add_column :notes, :category, :string
  end

  def down
    remove_column :notes, :category if column_exists?(:notes, :category)
  end
end
