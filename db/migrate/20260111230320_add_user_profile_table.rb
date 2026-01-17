class AddUserProfileTable < ActiveRecord::Migration[8.0]
  def up
    create_table :user_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :profile_picture
      t.string :bio
      t.string :location
      t.jsonb :professional_info, default: {}
    end unless table_exists?(:user_profiles)

    def down
      drop_table :user_profiles
    end

    add_index :user_profiles, :user_id, unique: true unless index_exists?(:user_profiles, :user_id) unless index_exists?(:user_profiles, :user_id)
  end
end
