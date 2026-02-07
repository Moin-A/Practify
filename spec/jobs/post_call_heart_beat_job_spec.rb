require 'rails_helper'

RSpec.describe PostCallHeartBeatJob, type: :job do
  let(:publisher) { create(:user) }
  let(:subscriber) { create(:user) }
  let(:calendar) { create(:calendar, user: publisher) }
  let(:slot) { create(:slot, calendar: calendar) }
  let(:appointment) { create(:appointment, publisher: publisher, subscriber: subscriber, slot: slot, publisher_joined: publisher_joined, subscriber_joined: subscriber_joined, status: initial_status) }

  let(:furure_start_time) { 1.hour.from_now }
  let(:furure_end_time) { 2.hours.from_now }
  let(:past_start_time) { 1.hour.ago }
  let(:past_end_time) { 2.hours.ago }
  let(:publisher_joined) { false }
  let(:subscriber_joined) { false }
  let(:initial_status) { :pending }

  describe '#perform' do
    context 'when both publisher_joined and subscriber_joined are true' do
      let(:publisher_joined) { true }
      let(:subscriber_joined) { true }
      context 'when slot is in the future' do
      before do
        slot.update_column(:start_at, furure_start_time)
        slot.update_column(:end_at, furure_end_time)
      end

        it 'sets the appointment status to pending' do
          expect {
            described_class.perform_now
          }.not_to change { appointment.reload.status }
          expect(appointment.reload.status).to eq('pending')
        end
      end
    end

    context 'when both publisher_joined and subscriber_joined are false' do
      let(:publisher_joined) { false }
      let(:subscriber_joined) { false }
      context 'when time has passed' do
        before do
          slot.update_column(:start_at, past_start_time)
          slot.update_column(:end_at, past_end_time)
        end

        it 'sets the appointment status to noshow' do
          expect {
            described_class.perform_now
          }.to change { appointment.reload.status }.from('pending').to('noshow')
        end
      end
    end



    context 'when appointment has not reached (start_at is in the future)' do
      let(:start_time) { 1.hour.from_now }
      let(:end_time) { 2.hours.from_now }

      it 'sets the appointment status to pending' do
        expect {
          described_class.perform_now
        }.not_to change { appointment.reload.status }
        expect(appointment.reload.status).to eq('pending')
      end
    end

    context 'when appointment is currently in progress (between start_at and end_at)' do
      let(:start_time) { 1.hour.ago }
      let(:end_time) { 30.minutes.ago }
      let(:publisher_joined) { false }
      let(:subscriber_joined) { false }
      let(:slot) { create(:slot, calendar: calendar) }

      before do
        # Skip validation that requires start_at to be in the future
        slot.update_column(:start_at, start_time)
        slot.update_column(:end_at, end_time)
      end

      it 'sets the appointment status to noshow if neither has joined' do
        expect {
          described_class.perform_now
        }.to change { appointment.reload.status }.from('pending').to('noshow')
      end
    end

    context 'priority: completed status takes precedence over time checks' do
      let(:start_time) { 2.hours.ago }
      let(:end_time) { 1.hour.ago }
      let(:publisher_joined) { true }
      let(:subscriber_joined) { true }
      let(:slot) { create(:slot, calendar: calendar) }

      before do
        # Skip validation that requires start_at to be in the future
        slot.update_column(:start_at, start_time)
        slot.update_column(:end_at, end_time)
      end

      it 'sets status to completed even if time has passed' do
        expect {
          described_class.perform_now
        }.to change { appointment.reload.status }.from('pending').to('completed')
      end
    end

    context 'when appointment is in the ongoing process' do
      let(:start_time) { 1.hour.ago }
      let(:end_time) { 2.hours.from_now }
      let(:publisher_joined) { true }
      let(:subscriber_joined) { true }
      before do
        # Skip validation that requires start_at to be in the future
        slot.update_column(:start_at, start_time)
        slot.update_column(:end_at, end_time)
      end

      it 'sets status to in_progress' do
        expect {
          described_class.perform_now
        }.to change { appointment.reload.status }.from('pending').to('in_progress')
      end
    end
  end
end
