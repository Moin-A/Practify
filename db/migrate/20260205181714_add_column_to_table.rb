class AddColumnToTable < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :status, :integer, default: 0
  end
end
