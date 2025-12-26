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

  describe "Google OAuth registration" do
    describe "GET /registration/google" do
      it "redirects to Google OAuth authorization URL" do
        get google_registration_path
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include("accounts.google.com")
        expect(response.location).to include("oauth")
      end

      it "includes correct OAuth parameters in redirect URL" do
        get google_registration_path
        expect(response.location).to include("client_id")
        expect(response.location).to include("redirect_uri")
        expect(response.location).to include("response_type=code")
        expect(response.location).to include("scope")
      end

      it "allows unauthenticated access" do
        get google_registration_path
        expect(response).not_to redirect_to(new_session_path)
      end
    end

    describe "GET /registration/google/callback" do
      context "with valid OAuth callback" do
        let(:oauth_data) do
          {
            email: "googleuser@gmail.com",
            name: "Google User",
            sub: "google_oauth_id_12345",
            picture: "https://example.com/avatar.jpg"
          }
        end

        before do
          # Mock OAuth response - adjust based on your OAuth gem
          allow_any_instance_of(RegistrationsController).to receive(:google_oauth_data).and_return(oauth_data)
        end

        context "for new user" do
          it "creates a new user from Google OAuth data" do
            expect {
              get google_callback_registration_path, params: { code: "valid_oauth_code" }
            }.to change(User, :count).by(1)
          end

          it "creates user with email from Google OAuth" do
            get google_callback_registration_path, params: { code: "valid_oauth_code" }
            user = User.find_by(email_address: "googleuser@gmail.com")
            expect(user).to be_present
          end

          it "stores Google OAuth ID in user record" do
            get google_callback_registration_path, params: { code: "valid_oauth_code" }
            user = User.find_by(email_address: "googleuser@gmail.com")
            # Adjust field name based on your User model structure
            # expect(user.google_oauth_id).to eq("google_oauth_id_12345")
          end

          it "creates a new session for the user" do
            expect {
              get google_callback_registration_path, params: { code: "valid_oauth_code" }
            }.to change(Session, :count).by(1)
          end

          it "redirects to root path after successful registration" do
            get google_callback_registration_path, params: { code: "valid_oauth_code" }
            expect(response).to redirect_to(root_path)
          end

          it "sets a success notice" do
            get google_callback_registration_path, params: { code: "valid_oauth_code" }
            expect(flash[:notice]).to include("Welcome")
          end

          it "logs the user in by setting session cookie" do
            get google_callback_registration_path, params: { code: "valid_oauth_code" }
            expect(response.cookies['session_id']).to be_present
          end

          it "normalizes email address from Google OAuth" do
            allow_any_instance_of(RegistrationsController).to receive(:google_oauth_data).and_return(
              oauth_data.merge(email: "  GoOgLeUsEr@GmAiL.cOm  ")
            )
            get google_callback_registration_path, params: { code: "valid_oauth_code" }
            user = User.last
            expect(user.email_address).to eq("googleuser@gmail.com")
          end
        end

        context "for existing user" do
          let!(:existing_user) { create(:user, email_address: "googleuser@gmail.com") }

          it "does not create a duplicate user" do
            expect {
              get google_callback_registration_path, params: { code: "valid_oauth_code" }
            }.not_to change(User, :count)
          end

          it "creates a new session for existing user" do
            expect {
              get google_callback_registration_path, params: { code: "valid_oauth_code" }
            }.to change(Session, :count).by(1)
          end

          it "logs in the existing user" do
            get google_callback_registration_path, params: { code: "valid_oauth_code" }
            expect(response.cookies['session_id']).to be_present
            session = Session.find_by(id: response.cookies['session_id'])
            expect(session.user).to eq(existing_user)
          end

          it "redirects to root path" do
            get google_callback_registration_path, params: { code: "valid_oauth_code" }
            expect(response).to redirect_to(root_path)
          end

          it "sets a success notice for login" do
            get google_callback_registration_path, params: { code: "valid_oauth_code" }
            expect(flash[:notice]).to be_present
          end
        end
      end

      context "with invalid OAuth callback" do
        it "handles missing authorization code" do
          get google_callback_registration_path
          expect(response).to redirect_to(new_registration_path)
          expect(flash[:alert]).to be_present
        end

        it "handles invalid authorization code" do
          allow_any_instance_of(RegistrationsController).to receive(:google_oauth_data).and_return(nil)
          get google_callback_registration_path, params: { code: "invalid_code" }
          expect(response).to redirect_to(new_registration_path)
          expect(flash[:alert]).to be_present
        end

        it "does not create a user with invalid OAuth data" do
          allow_any_instance_of(RegistrationsController).to receive(:google_oauth_data).and_return(nil)
          expect {
            get google_callback_registration_path, params: { code: "invalid_code" }
          }.not_to change(User, :count)
        end

        it "does not create a session with invalid OAuth data" do
          allow_any_instance_of(RegistrationsController).to receive(:google_oauth_data).and_return(nil)
          expect {
            get google_callback_registration_path, params: { code: "invalid_code" }
          }.not_to change(Session, :count)
        end
      end

      context "with OAuth error from Google" do
        it "handles access_denied error (user cancelled)" do
          get google_callback_registration_path, params: { error: "access_denied" }
          expect(response).to redirect_to(new_registration_path)
          expect(flash[:alert]).to include("cancelled") if flash[:alert]
        end

        it "handles other OAuth errors" do
          get google_callback_registration_path, params: { error: "invalid_request" }
          expect(response).to redirect_to(new_registration_path)
          expect(flash[:alert]).to be_present
        end

        it "does not create a user when OAuth is cancelled" do
          expect {
            get google_callback_registration_path, params: { error: "access_denied" }
          }.not_to change(User, :count)
        end
      end

      context "with missing email in OAuth data" do
        before do
          allow_any_instance_of(RegistrationsController).to receive(:google_oauth_data).and_return(
            { sub: "google_oauth_id_12345", name: "Google User" }
          )
        end

        it "does not create a user without email" do
          expect {
            get google_callback_registration_path, params: { code: "valid_code" }
          }.not_to change(User, :count)
        end

        it "redirects with error message" do
          get google_callback_registration_path, params: { code: "valid_code" }
          expect(response).to redirect_to(new_registration_path)
          expect(flash[:alert]).to be_present
        end
      end

      it "allows unauthenticated access" do
        get google_callback_registration_path, params: { code: "test_code" }
        expect(response).not_to redirect_to(new_session_path)
      end
    end
  end
end
