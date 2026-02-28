require "test_helper"

class AppointmentResheduleServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @appointment = appointments(:one)
    @slot = slots(:available_one)
    @new_slot = slots(:available_two)
    @appointment.update!(slot: @slot)
  end

  test "successful reschedule with available slot" do
    service = AppointmentResheduleService.new(
      appointment: @appointment,
      slot: @slot,
      new_slot: @new_slot,
      appointment_params: { reschedule_selected_slot_id: @new_slot.id }
    )
    assert service.call
    assert_equal @new_slot.id, @appointment.reload.slot_id
    assert_empty service.errors
  end

  test "fails when no slot selected" do
    service = AppointmentResheduleService.new(
      appointment: @appointment,
      slot: @slot,
      new_slot: nil,
      appointment_params: {}
    )
    refute service.call
    assert_includes service.errors, "No slot selected for reschedule"
  end

  test "fails when selected slot is unavailable" do
    unavailable_slot = slots(:unavailable_one)
    service = AppointmentResheduleService.new(
      appointment: @appointment,
      slot: @slot,
      new_slot: unavailable_slot,
      appointment_params: { reschedule_selected_slot_id: unavailable_slot.id }
    )
    refute service.call
    assert_includes service.errors, "Selected slot is not available"
  end
end
