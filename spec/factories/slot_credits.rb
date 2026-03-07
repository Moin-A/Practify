FactoryBot.define do
  factory :slot_credit do
    user { nil }
    slot_remaining { 1 }
    payment_order_id { "MyString" }
    payment_status { 1 }
    amount { 1 }
  end
end
