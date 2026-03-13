require 'rails_helper'

RSpec.describe SlotMutex, type: :model do
  describe '.with_lock!' do
    let(:slot) { create(:slot) }

    it 'raises ArgumentError when slot is not provided' do
      expect { SlotMutex.with_lock!(nil) }.to raise_error(ArgumentError, "Slot is required")
    end

    context 'when slot_mutex already exists' do
      before do
        create(:slot_mutex, slot: slot)
      end

      it 'raises an error when slot has already been used to create a SlotMutex' do
        expect { SlotMutex.with_lock!(slot) }.to raise_error(SlotMutex::LockFailed, "Slot mutex already exists")
      end
    end
  end
end
