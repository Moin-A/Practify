require 'rails_helper'

RSpec.describe "Appointments", type: :request do
  let(:user) { create(:user) }
  let(:session) { user.sessions.create!(ip_address: '127.0.0.1', user_agent: 'Test Browser') }
  let(:doctor) { create(:user) }
  let(:calendar) { create(:calendar, user: doctor) }
  let(:slot) { create(:slot, calendar: calendar, status: :available) }

  before do
    cookies.signed[:session_id] = session.id
  end

  describe "GET /appointments" do
    let!(:appointment1) { create(:appointment, user: user, slot: create(:slot, calendar: calendar, status: :available)) }
    let!(:appointment2) { create(:appointment, user: user, slot: create(:slot, calendar: calendar, status: :available)) }
    let!(:other_appointment) { create(:appointment) }

    it "returns http success" do
      get appointments_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /appointments/:id" do
    let(:appointment) { create(:appointment, user: user, slot: slot) }

    it "returns http success" do
      get appointment_path(appointment)
      expect(response).to have_http_status(:success)
    end

    it "prevents access to other user's appointments" do
      other_appointment = create(:appointment)
      expect {
        get appointment_path(other_appointment)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET /appointments/new" do
    it "returns http success" do
      get new_appointment_path(slot_id: slot.id)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /appointments" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          appointment: {
            notes: "Regular checkup"
          },
          slot_id: slot.id
        }
      end

      it "creates a new appointment" do
        expect {
          post appointments_path, params: valid_attributes
        }.to change(Appointment, :count).by(1)
      end

      it "redirects to the created appointment" do
        post appointments_path, params: valid_attributes
        expect(response).to redirect_to(appointment_path(Appointment.last))
      end

      it "associates appointment with current user" do
        post appointments_path, params: valid_attributes
        expect(Appointment.last.user).to eq(user)
      end

      it "associates appointment with slot" do
        post appointments_path, params: valid_attributes
        expect(Appointment.last.slot).to eq(slot)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          appointment: {
            notes: ""
          },
          slot_id: nil
        }
      end

      it "does not create a new appointment" do
        expect {
          post appointments_path, params: invalid_attributes
        }.not_to change(Appointment, :count)
      end

      it "renders the new template" do
        post appointments_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with unavailable slot" do
      let(:draft_slot) { create(:slot, calendar: calendar, status: :draft) }
      let(:invalid_attributes) do
        {
          appointment: {
            notes: "Regular checkup"
          },
          slot_id: draft_slot.id
        }
      end

      it "does not create a new appointment" do
        expect {
          post appointments_path, params: invalid_attributes
        }.not_to change(Appointment, :count)
      end
    end

    context "with already booked slot" do
      let!(:existing_appointment) { create(:appointment, slot: slot) }
      let(:invalid_attributes) do
        {
          appointment: {
            notes: "Regular checkup"
          },
          slot_id: slot.id
        }
      end

      it "does not create a new appointment" do
        expect {
          post appointments_path, params: invalid_attributes
        }.not_to change(Appointment, :count)
      end
    end
  end

  describe "GET /appointments/:id/edit" do
    let(:appointment) { create(:appointment, user: user, slot: slot) }

    it "returns http success" do
      get edit_appointment_path(appointment)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /appointments/:id" do
    let(:appointment) { create(:appointment, user: user, slot: slot) }

    context "with valid parameters" do
      let(:new_attributes) do
        {
          appointment: {
            notes: "Updated notes"
          }
        }
      end

      it "updates the appointment" do
        patch appointment_path(appointment), params: new_attributes
        appointment.reload
        expect(appointment.notes).to eq("Updated notes")
      end

      it "redirects to the appointment" do
        patch appointment_path(appointment), params: new_attributes
        expect(response).to redirect_to(appointment_path(appointment))
      end
    end
  end

  describe "DELETE /appointments/:id" do
    let!(:appointment) { create(:appointment, user: user, slot: slot) }

    it "destroys the appointment" do
      expect {
        delete appointment_path(appointment)
      }.to change(Appointment, :count).by(-1)
    end

    it "redirects to the appointments list" do
      delete appointment_path(appointment)
      expect(response).to redirect_to(appointments_path)
    end
  end

  describe "authentication requirement" do
    it "requires authentication" do
      cookies.delete(:session_id)
      get appointments_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
