require 'rails_helper'

RSpec.describe "Calendars", type: :request do
  let(:user) { create(:user) }
  let(:session) { user.sessions.create!(ip_address: '127.0.0.1', user_agent: 'Test Browser') }

  before do
    cookies.signed[:session_id] = session.id
  end

  describe "GET /calendars" do
    let!(:calendar1) { create(:calendar, user: user) }
    let!(:calendar2) { create(:calendar, user: user) }
    let!(:other_calendar) { create(:calendar) }

    it "returns http success" do
      get calendars_path
      expect(response).to have_http_status(:success)
    end

    it "only shows calendars for the current user" do
      get calendars_path
      expect(assigns(:calendars)).to include(calendar1, calendar2)
      expect(assigns(:calendars)).not_to include(other_calendar)
    end
  end

  describe "GET /calendars/:id" do
    let(:calendar) { create(:calendar, user: user) }

    it "returns http success" do
      get calendar_path(calendar)
      expect(response).to have_http_status(:success)
    end

    it "prevents access to other user's calendars" do
      other_calendar = create(:calendar)
      expect {
        get calendar_path(other_calendar)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET /calendars/new" do
    it "returns http success" do
      get new_calendar_path
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
          post calendars_path, params: valid_attributes
        }.to change(Calendar, :count).by(1)
      end

      it "redirects to the created calendar" do
        post calendars_path, params: valid_attributes
        expect(response).to redirect_to(calendar_path(Calendar.last))
      end

      it "associates calendar with current user" do
        post calendars_path, params: valid_attributes
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

      it "does not create a new calendar" do
        expect {
          post calendars_path, params: invalid_attributes
        }.not_to change(Calendar, :count)
      end

      it "renders the new template" do
        post calendars_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /calendars/:id/edit" do
    let(:calendar) { create(:calendar, user: user) }

    it "returns http success" do
      get edit_calendar_path(calendar)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /calendars/:id" do
    let(:calendar) { create(:calendar, user: user) }

    context "with valid parameters" do
      let(:new_attributes) do
        {
          calendar: {
            name: "Updated Calendar",
            timezone: "America/New_York"
          }
        }
      end

      it "updates the calendar" do
        patch calendar_path(calendar), params: new_attributes
        calendar.reload
        expect(calendar.name).to eq("Updated Calendar")
        expect(calendar.timezone).to eq("America/New_York")
      end

      it "redirects to the calendar" do
        patch calendar_path(calendar), params: new_attributes
        expect(response).to redirect_to(calendar_path(calendar))
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

      it "does not update the calendar" do
        original_name = calendar.name
        patch calendar_path(calendar), params: invalid_attributes
        calendar.reload
        expect(calendar.name).to eq(original_name)
      end

      it "renders the edit template" do
        patch calendar_path(calendar), params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /calendars/:id" do
    let!(:calendar) { create(:calendar, user: user) }

    it "destroys the calendar" do
      expect {
        delete calendar_path(calendar)
      }.to change(Calendar, :count).by(-1)
    end

    it "redirects to the calendars list" do
      delete calendar_path(calendar)
      expect(response).to redirect_to(calendars_path)
    end
  end

  describe "authentication requirement" do
    it "requires authentication" do
      cookies.delete(:session_id)
      get calendars_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
