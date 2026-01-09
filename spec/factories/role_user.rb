FactoryBot.define do
    factory :role_user do
        role { create(:role) }
        user { create(:user) }
    end
end
