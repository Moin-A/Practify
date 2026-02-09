module SlotsHelper
  def slot_id(slot)
    "slot_#{slot.id}"
  end

  def next_day_available_slots(date)
    slots = Slot.available_on(date).available.order(start_at: :asc)
    slots.map { |slot| { time: slot.start_at.strftime("%I:%M %p"), id: slot.id } }
  end

  def next_day
    @next_day ||= Time.current + 1.day
  end

  def selected_slot
    return nil unless selected_slot_id
    Slot.find_by(id: selected_slot_id)
  end

  def appointment_created?(slot_id)
    slot = Slot.find_by(id: slot_id)
    slot.present? && slot.appointment.present?
  end

  def appointment_created_by_current_user?(slot_id)
    slot = Slot.find_by(id: slot_id)
    slot.present? && slot.appointment.present? && slot.appointment.user_id == current_user.id
  end

  def slot_selected?(slot_id, selected_slot_id)
    selected_slot_id.to_s == slot_id.to_s
  end
end
