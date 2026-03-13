require 'rails_helper'
require 'support/cookie_helpers'

RSpec.describe "Appointments", type: :request do
  let(:client_role) { Role.find_or_create_by!(name: "Client") }
  let(:user) { create(:user).tap { |u| u.roles << client_role unless u.roles.include?(client_role) } }
  let(:super_admin_role) { Role.find_or_create_by!(name: "SuperAdmin") }
  let(:super_admin_user) { create(:user).tap { |u| u.roles << super_admin_role unless u.roles.include?(super_admin_role) } }
  let(:session) { user.sessions.create!(ip_address: '127.0.0.1', user_agent: 'Test Browser') }
  let(:doctor) { create(:user) }
  let(:calendar) { create(:calendar, user: doctor) }
  let(:slot) { create(:slot, calendar: calendar, status: :available) }

  before do
    session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Browser")
    set_signed_cookie(:session_id, session.id)
  end

  describe "GET /appointments" do
    let!(:appointment1) { create(:appointment, user: user, slot: create(:slot, calendar: calendar, status: :available)) }
    let!(:appointment2) { create(:appointment, user: user, slot: create(:slot, calendar: calendar, status: :available)) }
    let!(:other_appointment) { create(:appointment) }

    it "returns http success" do
      get appointments_path, headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("application/json")
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.map { |a| a["id"] }).to contain_exactly(appointment1.id, appointment2.id)
    end
  end

  describe "GET /appointments/:id" do
    let(:appointment) { create(:appointment, user: user, slot: slot) }

    it "returns http success" do
      get appointment_path(appointment, selected_slot_id: slot.id)
      expect(response).to have_http_status(:success)
    end

    it "prevents access to other user's appointments" do
      other_appointment = create(:appointment)
      get appointment_path(other_appointment)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end



  describe "POST /appointments" do
    let(:appointment) { create(:appointment, user: user, slot: slot) }

    before do
      allow_any_instance_of(AppointmentsController).to receive(:require_payment)
    end

    context "with valid parameters" do
      let(:valid_attributes) do
        {
          appointment: {
            slot_id: slot.id
          }
        }
      end

      it "creates a new appointment" do
        expect {
          post appointments_path, params: valid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.to change(Appointment, :count).by(1)
      end

      it "returns turbo_stream response" do
        post appointments_path, params: valid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end

      it "associates appointment with current user" do
        post appointments_path, params: valid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(Appointment.last.user).to eq(user)
      end

      it "associates appointment with slot" do
        post appointments_path, params: valid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(Appointment.last.slot).to eq(slot)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          appointment: {
            slot_id: nil
          }
        }
      end

      it "does not create a new appointment" do
        expect {
          post appointments_path, params: invalid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.not_to change(Appointment, :count)
      end

      it "returns unprocessable_entity status" do
        post appointments_path, params: invalid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end
    end

    context "with unavailable slot" do
      let(:draft_slot) { create(:slot, calendar: calendar, status: :draft) }
      let(:invalid_attributes) do
        {
          appointment: {
            slot_id: draft_slot.id
          }
        }
      end

      it "does not create a new appointment" do
        expect {
          post appointments_path, params: invalid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.not_to change(Appointment, :count)
      end

      it "returns unprocessable_entity status" do
        post appointments_path, params: invalid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with already booked slot" do
      let!(:existing_appointment) { create(:appointment, slot: slot) }
      let(:invalid_attributes) do
        {
          appointment: {
            slot_id: slot.id
          }
        }
      end

      it "does not create a new appointment" do
        expect {
          post appointments_path, params: invalid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.not_to change(Appointment, :count)
      end

      it "returns unprocessable_entity status" do
        post appointments_path, params: invalid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /appointments/:id/edit" do
    let(:appointment) { create(:appointment, user: user, slot: slot) }

    it "returns http success" do
      get edit_appointment_path(appointment), params: { appointment: { slot_id: slot.id } }
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



      it "redirects to the appointment" do
        patch appointment_path(appointment), params: new_attributes
        expect(response).to redirect_to(appointment_path(appointment))
      end
    end
  end

  describe "DELETE /appointments/:id" do
    let!(:appointment) { create(:appointment, user: user, slot: slot) }

    it "destroys the appointment" do
      session = super_admin_user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Browser")
      set_signed_cookie(:session_id, session.id)
      slot1 = create(:slot, calendar: calendar, status: :available)
      appointment1 = create(:appointment, user: super_admin_user, slot: slot1)
      expect {
        delete appointment_path(appointment1)
      }.to change(Appointment, :count).by(-1)
    end

    it "raises an error when user is a client" do
      doctor = create(:user)
      doctor.roles << Role.find_or_create_by!(name: "Doctor")
      delete appointment_path(appointment)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /appointments/:id/has_joined" do
    let(:appointment) { create(:appointment, user: user, slot: slot) }
    let(:doctor) { create(:user) }
    let(:appointment2) { create(:appointment, user: doctor, slot: slot, publisher: doctor, subscriber: user) }

    it "returns http success" do
      post has_joined_appointment_path(appointment), headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("application/json")
    end

    it "updates the joined status" do
      session = doctor.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Browser")
      set_signed_cookie(:session_id, session.id)
      post has_joined_appointment_path(appointment2), headers: { "Accept" => "application/json" }
      expect(appointment2.reload.publisher_joined).to be_truthy
    end

    it "updates the subscriber joined status" do
      post has_joined_appointment_path(appointment), headers: { "Accept" => "application/json" }
      expect(appointment.reload.subscriber_joined).to be_truthy
    end

    it "returns unprocessable entity when the appointment is not found" do
      post has_joined_appointment_path(9999), headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to include("application/json")
    end
  end


  describe "authentication requirement" do
    it "requires authentication" do
      Session.destroy_all
      cookies.delete(:session_id)
      Current.session = nil
      get appointments_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'POST #create' do
    it 'publishes a note_created event' do
      allow_any_instance_of(AppointmentsController).to receive(:require_payment)

      expect(Practify.bus).to receive(:publish).with(
        :appointment_created, hash_including(appointment: instance_of(Appointment))
      )
      post appointments_path, params:  { appointment: { slot_id: slot.id }
      }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
  end
end
