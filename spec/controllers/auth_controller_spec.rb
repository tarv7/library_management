require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  describe 'POST #create' do
    let!(:user) do
      User.create!(
        name: 'Test User',
        email_address: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        role: 'member'
      )
    end

    let(:valid_params) do
      {
        user: {
          email_address: 'test@example.com',
          password: 'password123'
        }
      }
    end

    let(:invalid_email_params) do
      {
        user: {
          email_address: 'nonexistent@example.com',
          password: 'password123'
        }
      }
    end

    let(:invalid_password_params) do
      {
        user: {
          email_address: 'test@example.com',
          password: 'wrongpassword'
        }
      }
    end

    context 'when credentials are valid' do
      it 'returns a successful response' do
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
      end

      it 'returns a valid JWT token that can be decoded' do
        post :create, params: valid_params

        token = json_response['token']

        decoded_token = JsonWebToken.decode(token)
        expect(decoded_token).to be_present
        expect(decoded_token[:user_id]).to eq(user.id)
        expect(decoded_token[:exp]).to be > Time.current.to_i
      end
    end

    context 'when email is invalid' do
      it 'returns unauthorized status' do
        post :create, params: invalid_email_params

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        post :create, params: invalid_email_params

        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'does not return a token' do
        post :create, params: invalid_email_params

        expect(json_response).not_to have_key('token')
      end
    end

    context 'when password is invalid' do
      it 'returns unauthorized status' do
        post :create, params: invalid_password_params

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        post :create, params: invalid_password_params

        expect(json_response).to have_key('error')
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'does not return a token' do
        post :create, params: invalid_password_params

        expect(json_response).not_to have_key('token')
      end
    end

    context 'with different user roles' do
      let!(:librarian) do
        User.create!(
          name: 'Librarian User',
          email_address: 'librarian@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          role: 'librarian'
        )
      end

      let!(:member) do
        User.create!(
          name: 'Member User',
          email_address: 'member@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          role: 'member'
        )
      end

      it 'authenticates librarian successfully' do
        params = {
          user: {
            email_address: 'librarian@example.com',
            password: 'password123'
          }
        }

        post :create, params: params

        expect(response).to have_http_status(:created)
        token = json_response['token']
        decoded_token = JsonWebToken.decode(token)
        expect(decoded_token[:user_id]).to eq(librarian.id)
      end

      it 'authenticates member successfully' do
        params = {
          user: {
            email_address: 'member@example.com',
            password: 'password123'
          }
        }

        post :create, params: params

        expect(response).to have_http_status(:created)
        token = json_response['token']
        decoded_token = JsonWebToken.decode(token)
        expect(decoded_token[:user_id]).to eq(member.id)
      end
    end
  end
end
