require 'rails_helper'

RSpec.describe "Slots", type: :request do
  let(:user) { create(:user) }
  let(:session) { user.sessions.create!(ip_address: '127.0.0.1', user_agent: 'Test Browser') }
  let(:calendar) { create(:calendar, user: user) }

  before do
    cookies.signed[:session_id] = session.id
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

      it "redirects to the created slot" do
        post calendar_slots_path(calendar), params: valid_attributes
        expect(response).to redirect_to(calendar_slot_path(calendar, Slot.last))
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

  describe "GET /calendars/:calendar_id/slots/:id/edit" do
    let(:slot) { create(:slot, calendar: calendar) }

    it "returns http success" do
      get edit_calendar_slot_path(calendar, slot)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /calendars/:calendar_id/slots/:id" do
    let(:slot) { create(:slot, calendar: calendar) }

    context "with valid parameters" do
      let(:new_attributes) do
        {
          slot: {
            start_at: 2.days.from_now.iso8601,
            end_at: 2.days.from_now + 2.hours,
            status: "draft"
          }
        }
      end

      it "updates the slot" do
        patch calendar_slot_path(calendar, slot), params: new_attributes
        slot.reload
        expect(slot.status).to eq("draft")
      end

      it "redirects to the slot" do
        patch calendar_slot_path(calendar, slot), params: new_attributes
        expect(response).to redirect_to(calendar_slot_path(calendar, slot))
      end
    end
  end

  describe "DELETE /calendars/:calendar_id/slots/:id" do
    let!(:slot) { create(:slot, calendar: calendar) }

    it "destroys the slot" do
      expect {
        delete calendar_slot_path(calendar, slot)
      }.to change(Slot, :count).by(-1)
    end

    it "redirects to the slots list" do
      delete calendar_slot_path(calendar, slot)
      expect(response).to redirect_to(calendar_slots_path(calendar))
    end
  end

  describe "authentication requirement" do
    it "requires authentication" do
      cookies.delete(:session_id)
      get calendar_slots_path(calendar)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
