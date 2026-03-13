require 'rails_helper'
require 'support/cookie_helpers'
require 'ostruct'

RSpec.describe SlotMutex, type: :model do
  describe '.with_lock!' do
    let(:slot) { create(:slot, user: user2) }
    let(:user) { create(:user) }
    let(:user2) { create(:user) }

    it 'raises ArgumentError when slot is not provided' do
      expect { SlotMutex.with_lock!(nil) }.to raise_error(ArgumentError, "Slot is required")
    end

    context 'when slot_mutex already exists' do
      before do
        session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Browser")
        Current.session = OpenStruct.new(user: user)
        create(:slot_mutex, slot: slot, held_by_user: user2)
      end

      it 'raises an error when slot has already been used to create a SlotMutex' do
        expect { SlotMutex.with_lock!(slot) { puts "done" } }.to raise_error(SlotMutex::LockFailed, "Slot mutex already exists")
      end
    end
  end
end
