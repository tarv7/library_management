# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Auth', type: :request do
  path '/api/v1/auth' do
    post('User authentication') do
      tags 'Authentication'
      description 'Authenticates a user with email and password, returns JWT token on success'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            '$ref' => '#/components/schemas/LoginInput'
          }
        },
        required: [ 'user' ]
      }

      response(201, 'Authentication successful') do
        schema '$ref' => '#/components/schemas/AuthToken'

        before do
          User.create!(
            email_address: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            name: 'Test User',
            role: 'member'
          )
        end

        let(:user) do
          {
            user: {
              email_address: 'test@example.com',
              password: 'password123'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['token']).to be_present
          expect(data['token']).to be_a(String)

          decoded_token = JsonWebToken.decode(data['token'])
          expect(decoded_token[:user_id]).to be_present
          expect(decoded_token[:email_address]).to eq('test@example.com')
          expect(decoded_token[:name]).to eq('Test User')
          expect(decoded_token[:role]).to eq('member')
          expect(decoded_token[:created_at]).to be_present
          expect(decoded_token[:exp]).to be > Time.current.to_i
        end
      end

      response(401, 'Invalid credentials') do
        schema '$ref' => '#/components/schemas/AuthError'

        context 'with invalid email' do
          let(:user) do
            {
              user: {
                email_address: 'nonexistent@example.com',
                password: 'password123'
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['error']).to eq('Invalid email or password')
          end
        end
      end

      response(401, 'Invalid password') do
        schema '$ref' => '#/components/schemas/AuthError'

        before do
          User.create!(
            email_address: 'existing@example.com',
            password: 'correct_password',
            password_confirmation: 'correct_password',
            name: 'Existing User',
            role: 'member'
          )
        end

        let(:user) do
          {
            user: {
              email_address: 'existing@example.com',
              password: 'wrong_password'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Invalid email or password')
        end
      end

      response(401, 'Empty credentials') do
        schema '$ref' => '#/components/schemas/AuthError'

        let(:user) do
          {
            user: {
              email_address: '',
              password: ''
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Invalid email or password')
        end
      end
    end
  end
end
