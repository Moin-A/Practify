require 'rails_helper'

RSpec.describe Slot, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      slot = build(:slot, calendar: create(:calendar, user: create(:user)))
      expect(slot).to be_valid
    end

    it 'requires a start_at' do
      slot = build(:slot, start_at: nil)
      expect(slot).not_to be_valid
      expect(slot.errors[:start_at]).to include("can't be blank")
    end

    it 'requires an end_at' do
      slot = build(:slot, end_at: nil)
      expect(slot).not_to be_valid
      expect(slot.errors[:end_at]).to include("can't be blank")
    end

    it 'required a slot having a present or future start_at' do
      slot = build(:slot, start_at: 1.day.ago, calendar: create(:calendar, user: create(:user)))
      expect(slot).not_to be_valid
      expect(slot.errors[:start_at]).to include("must be present or future")
    end

    it 'requires end_at to be after start_at' do
      slot = build(:slot, start_at: 1.day.from_now, end_at: 1.day.ago)
      expect(slot).not_to be_valid
      expect(slot.errors[:end_at]).to include("must be after start_at")
    end

    it 'requires a calendar_id' do
      slot = build(:slot, calendar_id: nil)
      expect(slot).not_to be_valid
      expect(slot.errors[:calendar_id]).to include("can't be blank")
    end

    it 'requires a calendar to be present' do
      slot = build(:slot, calendar: nil)
      expect(slot).not_to be_valid
      expect(slot.errors[:calendar]).to include("must exist")
    end
  end


  describe 'status enum' do
    it 'has draft status by default' do
      slot = Slot.new
      expect(slot.status).to eq('draft')
    end

    it 'can be set to available' do
      slot = build(:slot, status: :available)
      expect(slot.status).to eq('available')
    end

    it 'can be set to draft' do
      slot = build(:slot, status: :draft)
      expect(slot.status).to eq('draft')
    end
  end

  describe 'associations' do
    let(:slot) { create(:slot) }

    it 'belongs to a calendar' do
      expect(slot).to respond_to(:calendar)
      expect(slot.calendar).to be_a(Calendar)
    end

    it 'has one appointment' do
      expect(slot).to respond_to(:appointment)
      appointment = create(:appointment, slot: slot)
      expect(slot.appointment).to eq(appointment)
    end

    it 'destroys associated appointment when slot is destroyed' do
      appointment = create(:appointment, slot: slot)
      appointment_id = appointment.id

      slot.destroy

      expect(Appointment.find_by(id: appointment_id)).to be_nil
    end
  end
end
