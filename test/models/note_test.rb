require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "contextable association and STI work" do
    # Create a user (email_address column is used in the model)
    user = User.create!(email_address: "test@example.com", password: "password")

    # Create a calendar for the user (required for slot)
    calendar = Calendar.create!(user: user, timezone: "UTC")

    # Create an available slot
    slot = Slot.create!(
      calendar: calendar,
      start_at: 1.day.from_now,
      end_at: 1.day.from_now + 1.hour,
      status: :available
    )

    # Create an appointment linked to the slot
    appointment = Appointment.create!(user: user, slot: slot, status: :booked)

    # Create an AppointmentNote linked via the polymorphic contextable association
    note = AppointmentNote.create!(
      notable: user,
      category: "note",
      body: "test note",
      contextable: appointment
    )

    assert_equal appointment, note.contextable
    assert_equal "AppointmentNote", note.type
  end
end
