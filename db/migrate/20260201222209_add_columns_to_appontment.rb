class AddColumnsToAppontment < ActiveRecord::Migration[8.0]
  def up
    add_column :appointments, :publisher_joined, :boolean, default: false unless column_exists?(:appointments, :publisher_joined)
    add_column :appointments, :subscriber_joined, :boolean, default: false unless column_exists?(:appointments, :subscriber_joined)
  end

  def down
    remove_column :appointments, :publisher_joined if column_exists?(:appointments, :publisher_joined)
    remove_column :appointments, :subscriber_joined if column_exists?(:appointments, :subscriber_joined)
  end
end
