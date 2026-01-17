require 'rails_helper'

RSpec.describe Calendar, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      calendar = build(:calendar)
      expect(calendar).to be_valid
    end

    it 'requires a name' do
      calendar = build(:calendar, name: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:name]).to include("can't be blank")
    end

    it 'requires a timezone' do
      calendar = build(:calendar, timezone: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:timezone]).to include("can't be blank")
    end

    it 'requires a user_id' do
      calendar = build(:calendar, user_id: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:user_id]).to include("can't be blank")
    end
  end

  describe 'associations' do
    let(:calendar) { create(:calendar) }

    it 'belongs to a user' do
      expect(calendar).to respond_to(:user)
      expect(calendar.user).to be_a(User)
    end

    it 'has many slots' do
      expect(calendar).to respond_to(:slots)
      slot = create(:slot, calendar: calendar)
      expect(calendar.slots).to include(slot)
    end

    it 'destroys associated slots when calendar is destroyed' do
      slot = create(:slot, calendar: calendar)
      slot_id = slot.id

      calendar.destroy

      expect(Slot.find_by(id: slot_id)).to be_nil
    end
  end
end
