require 'rails_helper'
require 'debug'
require 'pry'
RSpec.describe "Registrations", type: :request do
  before do
    OmniAuth.config.test_mode = true  # No real HTTP requests to Google
    
    # Stub the OAuth response
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: '12345',
      info: { email: 'test@example.com', name: 'Test User' }
    })
  end

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
        get '/auth/google_oauth2'        
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include("auth/google_oauth2/callback")        
      end
     

      it "allows unauthenticated access" do
        get '/auth/google_oauth2'        
        expect(response).not_to redirect_to(new_session_path)
      end
    end

    describe "GET /registration/google/callback" do
      context "with valid OAuth callback" do       
       
        context "for new user" do
          it "creates a new user from Google OAuth data" do
            expect {
              get '/auth/google_oauth2/callback'
            }.to change(User, :count).by(1)
          end

          it "creates user with email from Google OAuth" do
            get '/auth/google_oauth2/callback'
            user = User.find_by(email_address: "test@example.com")
            expect(user).to be_present
          end

          it "stores Google OAuth ID in user record" do
            get '/auth/google_oauth2/callback'
            user = User.find_by(email_address: "test@example.com")
            expect(user.uid).to eq("12345")
          end

          it "creates a new session for the user" do
            expect {
              get '/auth/google_oauth2/callback'
            }.to change(Session, :count).by(1)
          end

          it "redirects to root path after successful registration" do
            get '/auth/google_oauth2/callback'
            expect(response).to redirect_to(root_path)
          end

          it "sets a success notice" do
            get '/auth/google_oauth2/callback'
            expect(flash[:notice]).to include("Successfully signed in with Google!")
          end

          it "logs the user in by setting session cookie" do
            get '/auth/google_oauth2/callback'
            expect(response.cookies['session_id']).to be_present
          end

          it "normalizes email address from Google OAuth" do
            OmniAuth.config.mock_auth[:google_oauth2][:info][:email] = "  GoOgLeUsEr@GmAiL.cOm  "
            get '/auth/google_oauth2/callback'
            user = User.last
            expect(user.email_address).to eq("googleuser@gmail.com")
          end
        end

        context "for existing user" do
          let!(:existing_user) { create(:user, email_address: "test@example.com") }

          it "does not create a duplicate user" do
            expect {
              get '/auth/google_oauth2/callback'
            }.not_to change(User, :count)
          end

          it "creates a new session for existing user" do
            expect {
              get '/auth/google_oauth2/callback'
            }.to change(Session, :count).by(1)
          end

          it "logs in the existing user" do
            get '/auth/google_oauth2/callback'
            expect(response.cookies['session_id']).to be_present
            jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
            session = Session.find_by(id: jar.signed["session_id"])            
            expect(session.user).to eq(existing_user)
          end

          it "redirects to root path" do
            get '/auth/google_oauth2/callback'
            expect(response).to redirect_to(root_path)
          end

          it "sets a success notice for login" do
            get '/auth/google_oauth2/callback'
            expect(flash[:notice]).to be_present
          end
        end
      end

    

      context "with OAuth error from Google" do
        it "handles access_denied error (user cancelled)" do
          OmniAuth.config.mock_auth[:google_oauth2] = nil
          get '/auth/google_oauth2/callback', params: { error: "access_denied" }          
          expect(response).to redirect_to(new_session_path)
          expect(flash[:alert]).to include("Failed to sign in with Google. Email address can't be blank") if flash[:alert]
        end

        it "handles other OAuth errors" do
          OmniAuth.config.mock_auth[:google_oauth2] = nil
          get '/auth/google_oauth2/callback', params: { error: "invalid_request" }
           expect(response).to redirect_to(new_session_path)
          expect(flash[:alert]).to be_present
        end

        it "does not create a user when OAuth is cancelled" do
          OmniAuth.config.mock_auth[:google_oauth2] = nil
          expect {
            get '/auth/google_oauth2/callback'
          }.not_to change(User, :count)
        end
      end

      context "with missing email in OAuth data" do
         OmniAuth.config.mock_auth[:google_oauth2] = nil
        before do
          allow_any_instance_of(SessionsController).to receive(:omniauth).and_return(
            { sub: "google_oauth_id_12345", name: "Google User" }
          )
        end

        it "does not create a user without email" do
          OmniAuth.config.mock_auth[:google_oauth2] = nil
          expect {
            get '/auth/google_oauth2/callback'
          }.not_to change(User, :count)
        end
        
      end

      it "allows unauthenticated access" do
        get '/auth/google_oauth2/callback', params: { code: "test_code" }
        expect(response).not_to redirect_to(new_session_path)
      end
    end
  end
end
