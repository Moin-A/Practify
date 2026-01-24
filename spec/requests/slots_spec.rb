require 'rails_helper'
require 'support/cookie_helpers'

RSpec.describe "Slots", type: :request do
  let(:user) { create(:user) }
  let(:session) { user.sessions.create!(ip_address: '127.0.0.1', user_agent: 'Test Browser') }
  let(:calendar) { create(:calendar, user: user) }

  before do
    session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Browser")
    set_signed_cookie(:session_id, session.id)
  end

  describe "GET /calendars/:calendar_id/slots" do
    let!(:slot1) { create(:slot, calendar: calendar) }
    let!(:slot2) { create(:slot, calendar: calendar) }
    let!(:other_slot) { create(:slot) }

    it "returns http success" do
      get calendar_slots_path(calendar)
      expect(response).to have_http_status(:success)
    end

    it "only shows slots for the calendar" do
      get calendar_slots_path(calendar)
      expect(assigns(:slots)).to include(slot1, slot2)
      expect(assigns(:slots)).not_to include(other_slot)
    end
  end

  describe "GET /calendars/:calendar_id/slots/:id" do
    let(:slot) { create(:slot, calendar: calendar) }

    it "returns http success" do
      get calendar_slot_path(calendar, slot)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /calendars/:calendar_id/slots/new" do
    it "returns http success" do
      get new_calendar_slot_path(calendar)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /calendars/:calendar_id/slots" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          slot: {
            start_at: 1.day.from_now.iso8601,
            end_at: 1.day.from_now + 1.hour,
            status: "available"
          }
        }
      end

      it "creates a new slot" do
        expect {
          post calendar_slots_path(calendar), params: valid_attributes
        }.to change(Slot, :count).by(1)
      end

      it "returns turbo stream response" do
        post calendar_slots_path(calendar), params: valid_attributes, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end

      it "associates slot with calendar" do
        post calendar_slots_path(calendar), params: valid_attributes
        expect(Slot.last.calendar).to eq(calendar)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          slot: {
            start_at: "",
            end_at: "",
            status: ""
          }
        }
      end

      it "does not create a new slot" do
        expect {
          post calendar_slots_path(calendar), params: invalid_attributes
        }.not_to change(Slot, :count)
      end

      it "renders the new template" do
        post calendar_slots_path(calendar), params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with end_at before start_at" do
      let(:invalid_attributes) do
        {
          slot: {
            start_at: 1.day.from_now.iso8601,
            end_at: 1.day.ago.iso8601,
            status: "available"
          }
        }
      end

      it "does not create a new slot" do
        expect {
          post calendar_slots_path(calendar), params: invalid_attributes
        }.not_to change(Slot, :count)
      end
    end
  end





  describe "authentication requirement" do
    it "requires authentication" do
      Session.destroy_all
      cookies.delete(:session_id)
      get calendar_slots_path(calendar)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
