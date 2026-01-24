FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user-#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }


    after(:create) do |user|
        user.create_user_profile!(
          first_name: "John",
          last_name: "Doe"
        )
      end
    end
  end
