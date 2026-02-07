require 'rails_helper'
require 'support/cookie_helpers'

RSpec.describe "Calendars", type: :request do
  let(:user) { create(:user) }
  let(:super_admin_user) { create(:user, :super_admin) }
  let(:calendar) { create(:calendar, user: user) }
  before do
    session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Browser")
    set_signed_cookie(:session_id, session.id)
  end

  describe "GET /calendars" do
    let!(:calendar1) { create(:calendar, user: user) }
    let!(:calendar2) { create(:calendar, user: user) }
    let!(:calendar3) { create(:calendar, user: super_admin_user) }
    let!(:other_calendar) { create(:calendar) }

    it "returns http success" do
      get calendar_schedule_path(calendar1)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /calendars/:id" do
    let(:calendar) { create(:calendar, user: super_admin_user) }

    before do
      session = super_admin_user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Browser")
      set_signed_cookie(:session_id, session.id)
    end

    it "returns http success" do
      get calendar_schedule_path(calendar)
      expect(response).to have_http_status(:success)
    end

    it "prevents access to other user's calendars" do
      other_calendar = create(:calendar)
      # Use regular user session for this test
      session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Browser")
      set_signed_cookie(:session_id, session.id)

      expect {
        get calendar_schedule_path(other_calendar)
      }.to raise_error(CanCan::AccessDenied, "You are not authorized to access this calendar")
    end
  end

  describe "GET /calendars/new" do
    it "returns http success" do
      get calendar_schedule_path(calendar)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /calendars" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          calendar: {
            name: "My Calendar",
            timezone: "UTC"
          }
        }
      end

      it "creates a new calendar" do
        expect {
          post calendar_schedule_path(calendar), params: valid_attributes
        }.to change(Calendar, :count).by(1)
      end


      it "associates calendar with current user" do
        post calendar_schedule_path(calendar), params: valid_attributes
        expect(Calendar.last.user).to eq(user)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          calendar: {
            name: "",
            timezone: ""
          }
        }
      end
    end
  end



  describe "authentication requirement" do
    it "requires authentication" do
     Session.destroy_all

      get calendar_schedule_path(calendar)
      expect(response).to redirect_to(new_session_url)
    end
  end
end
