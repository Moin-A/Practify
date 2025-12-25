require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /registration/new" do
    it "returns http success" do
      get new_registration_path
      expect(response).to have_http_status(:success)
    end

    it "displays the signup form" do
      get new_registration_path
      expect(response.body).to include("Sign Up")
      expect(response.body).to include("Sign up")
    end
  end

  describe "POST /registration" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          user: {
            email_address: "newuser@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates a new user" do
        expect {
          post registration_path, params: valid_attributes
        }.to change(User, :count).by(1)
      end

      it "creates a new session for the user" do
        expect {
          post registration_path, params: valid_attributes
        }.to change(Session, :count).by(1)
      end

      it "redirects to the root path" do
        post registration_path, params: valid_attributes
        expect(response).to redirect_to(root_path)
      end

      it "sets a success notice" do
        post registration_path, params: valid_attributes
        expect(flash[:notice]).to eq("Welcome! You have signed up successfully.")
      end

      it "logs the user in by setting session cookie" do
        post registration_path, params: valid_attributes
        expect(response.cookies['session_id']).to be_present
      end

      it "stores the correct session in the cookie" do
        post registration_path, params: valid_attributes
        # Verify a session was created for the new user
        user = User.find_by(email_address: "newuser@example.com")
        expect(user.sessions.count).to eq(1)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          user: {
            email_address: "",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "does not create a new user" do
        expect {
          post registration_path, params: invalid_attributes
        }.not_to change(User, :count)
      end

      it "does not create a session" do
        expect {
          post registration_path, params: invalid_attributes
        }.not_to change(Session, :count)
      end

      it "returns unprocessable entity status" do
        post registration_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays the form again with errors" do
        post registration_path, params: invalid_attributes
        expect(response.body).to include("Sign Up")
        expect(response.body).to include("error")
      end
    end

    context "with mismatched password confirmation" do
      let(:mismatched_attributes) do
        {
          user: {
            email_address: "newuser@example.com",
            password: "password123",
            password_confirmation: "different_password"
          }
        }
      end

      it "does not create a new user" do
        expect {
          post registration_path, params: mismatched_attributes
        }.not_to change(User, :count)
      end

      it "displays the form again with errors" do
        post registration_path, params: mismatched_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Sign Up")
      end
    end

    context "with duplicate email address" do
      let!(:existing_user) { create(:user, email_address: "existing@example.com") }
      
      let(:duplicate_attributes) do
        {
          user: {
            email_address: "existing@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "does not create a new user" do
        expect {
          post registration_path, params: duplicate_attributes
        }.not_to change(User, :count)
      end

      it "displays the form again with errors" do
        post registration_path, params: duplicate_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Sign Up")
      end
    end

    context "with normalized email" do
      let(:unnormalized_attributes) do
        {
          user: {
            email_address: "  NeWuSeR@ExAmPlE.cOm  ",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates user with normalized email" do
        post registration_path, params: unnormalized_attributes
        user = User.last
        expect(user.email_address).to eq("newuser@example.com")
      end
    end
  end

  describe "authentication requirement" do
    it "allows unauthenticated access to new" do
      get new_registration_path
      expect(response).to have_http_status(:success)
    end

    it "allows unauthenticated access to create" do
      post registration_path, params: {
        user: {
          email_address: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
      expect(response).not_to redirect_to(new_session_path)
    end
  end
end

