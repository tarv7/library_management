require 'rails_helper'

RSpec.describe "/api/v1/auth", type: :request do
  describe "POST /create" do
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
        post api_v1_auth_index_url, params: valid_params, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it 'returns a valid JWT token that can be decoded' do
        post api_v1_auth_index_url, params: valid_params, as: :json

        token = json_response['token']

        decoded_token = JsonWebToken.decode(token)
        expect(decoded_token).to be_present
        expect(decoded_token[:user_id]).to eq(user.id)
        expect(decoded_token[:email_address]).to eq(user.email_address)
        expect(decoded_token[:name]).to eq(user.name)
        expect(decoded_token[:role]).to eq(user.role)
        expect(decoded_token[:created_at]).to be_present
        expect(decoded_token[:exp]).to be > Time.current.to_i
      end
    end

    context 'when email is invalid' do
      it 'returns unauthorized status' do
        post api_v1_auth_index_url, params: invalid_email_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it 'returns an error message' do
        post api_v1_auth_index_url, params: invalid_email_params, as: :json

        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'does not return a token' do
        post api_v1_auth_index_url, params: invalid_email_params, as: :json

        expect(json_response).not_to have_key('token')
      end
    end

    context 'when password is invalid' do
      it 'returns unauthorized status' do
        post api_v1_auth_index_url, params: invalid_password_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it 'returns an error message' do
        post api_v1_auth_index_url, params: invalid_password_params, as: :json

        expect(json_response).to have_key('error')
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'does not return a token' do
        post api_v1_auth_index_url, params: invalid_password_params, as: :json

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

        post api_v1_auth_index_url, params: params, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
        token = json_response['token']
        decoded_token = JsonWebToken.decode(token)
        expect(decoded_token[:user_id]).to eq(librarian.id)
        expect(decoded_token[:email_address]).to eq(librarian.email_address)
        expect(decoded_token[:name]).to eq(librarian.name)
        expect(decoded_token[:role]).to eq('librarian')
        expect(decoded_token[:created_at]).to be_present
        expect(decoded_token[:exp]).to be > Time.current.to_i
      end

      it 'authenticates member successfully' do
        params = {
          user: {
            email_address: 'member@example.com',
            password: 'password123'
          }
        }

        post api_v1_auth_index_url, params: params, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
        token = json_response['token']
        decoded_token = JsonWebToken.decode(token)
        expect(decoded_token[:user_id]).to eq(member.id)
        expect(decoded_token[:email_address]).to eq(member.email_address)
        expect(decoded_token[:name]).to eq(member.name)
        expect(decoded_token[:role]).to eq('member')
        expect(decoded_token[:created_at]).to be_present
        expect(decoded_token[:exp]).to be > Time.current.to_i
      end
    end
  end
end
