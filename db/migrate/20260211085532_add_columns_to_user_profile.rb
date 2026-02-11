class AddColumnsToUserProfile < ActiveRecord::Migration[8.0]
  def up
    add_column :user_profiles, :gender, :string unless column_exists?(:user_profiles, :gender)
    add_column :user_profiles, :age, :integer unless column_exists?(:user_profiles, :age)
    add_column :user_profiles, :location, :string unless column_exists?(:user_profiles, :location)
  end

  def down
    if column_exists?(:user_profiles, :gender)
      remove_column :user_profiles, :gender
    end
    if column_exists?(:user_profiles, :age)
      remove_column :user_profiles, :age
    end
    if column_exists?(:user_profiles, :location)
      remove_column :user_profiles, :location
    end
  end
end
