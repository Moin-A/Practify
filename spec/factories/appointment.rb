FactoryBot.define do
  factory :appointment do
    notes { "Regular checkup" }
    association :user
    association :slot, status: :available
  end
end
