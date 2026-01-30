class InitializeUserProfile < ActiveRecord::Migration[8.0]
  def change
    User.all.each do |user|
      UserProfile.find_or_create_by!(user_id: user.id, first_name: user.email_address.split("@")[0], last_name: user.email_address.split("@")[1].split(".")[0])
    end
  end
end
