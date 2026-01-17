require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      appointment = build(:appointment)
      expect(appointment).to be_valid
    end

    it 'requires a user_id' do
      appointment = build(:appointment, user_id: nil)
      expect(appointment).not_to be_valid
      expect(appointment.errors[:user_id]).to include("can't be blank")
    end

    it 'requires a slot_id' do
      appointment = build(:appointment, slot_id: nil)
      expect(appointment).not_to be_valid
      expect(appointment.errors[:slot_id]).to include("can't be blank")
    end

    it 'requires a unique slot_id' do
      slot = create(:slot, status: :available)
      create(:appointment, slot: slot)
      duplicate_appointment = build(:appointment, slot: slot)
      expect(duplicate_appointment).not_to be_valid
      expect(duplicate_appointment.errors[:slot_id]).to include("has already been taken")
    end

    it 'requires slot to be available' do
      slot = create(:slot, status: :draft)
      appointment = build(:appointment, slot: slot)
      expect(appointment).not_to be_valid
      expect(appointment.errors[:slot_id]).to include("must be available")
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
      appointment = build(:appointment, slot: slot)

      expect(appointment).not_to be_valid
      expect(appointment.errors[:slot_id]).to include("must be available")
    end
  end
end
