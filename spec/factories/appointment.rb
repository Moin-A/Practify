FactoryBot.define do
  factory :appointment do
    notes { "Regular checkup" }
    association :user
    association :slot, status: :available

    after(:build) do |appointment|
      # Publisher is the slot's calendar owner (doctor)
      appointment.publisher ||= appointment.slot.user if appointment.slot&& appointment.slot.user && appointment.publisher.blank?
      # Subscriber is the user booking the appointment
      appointment.subscriber ||= appointment.user if appointment.user && appointment.subscriber.blank?
    end
  end
end
