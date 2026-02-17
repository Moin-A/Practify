require 'rails_helper'
require 'support/cookie_helpers'

RSpec.describe Appointment, type: :model do
  let(:user) { create(:user) }
  let(:role) { create(:role) }
  let(:role_user) { create(:role_user, user: user, role: role) }
  let(:slot) { create(:slot, status: :available) }
  let(:appointment) { build(:appointment, user: user, slot: slot) }
  let(:duplicate_appointment) { create(:appointment, slot: slot) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(appointment).to be_valid
    end

    it 'requires a user_id' do
      appointment = build(:appointment, user: nil)

      expect(appointment).not_to be_valid
      expect(appointment.errors[:user_id]).to include("can't be blank")
    end

    it 'requires a slot_id' do
      appointment = build(:appointment, slot: nil)
      expect(appointment).not_to be_valid
      expect(appointment.errors[:slot_id]).to include("can't be blank")
    end
  end

  describe 'associations' do
    let(:appointment) { create(:appointment) }

    it 'belongs to a user' do
      expect(appointment).to respond_to(:user)
      expect(appointment.user).to be_a(User)
    end

    it 'belongs to a slot' do
      expect(appointment).to respond_to(:slot)
      expect(appointment.slot).to be_a(Slot)
    end
  end

  describe 'custom validations' do
    it 'validates slot must be available before creating appointment' do
      slot = create(:slot, status: :draft)
      appointment = build(:appointment, user: user, slot: slot)
      expect(appointment).not_to be_valid
      expect(appointment.errors[:slot_id]).to include("must be available")
    end
  end

  describe 'save_and_notify' do
    it 'saves the appointment and notifies the user' do
      appointment = build(:appointment, user: user, slot: slot)
      expect(Practify.bus).to receive(:publish).with(:appointment_created, appointment: appointment)
      appointment.save_and_notify
    end
  end
end
