FactoryBot.define do
  factory :slot do
    start_at { 1.day.from_now }
    end_at { 1.day.from_now + 1.hour }
    status { :available }
    association :calendar
  end

  trait :draft do
    status { :draft }
  end

  trait :available do
    status { :available }
  end
end
