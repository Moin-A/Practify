FactoryBot.define do
  factory :calendar do
    name { "My Calendar" }
    timezone { "UTC" }
    association :user
  end
end
