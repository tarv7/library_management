# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  path '/api/v1/users' do
    post('Create a new user') do
      tags 'Users'
      description 'Creates a new user with the provided information. Can create both member and librarian users.'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            '$ref' => '#/components/schemas/UserInput'
          }
        },
        required: ['user']
      }

      response(201, 'User created successfully') do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 email_address: { type: :string, format: :email, example: 'user@example.com' },
                 name: { type: :string, example: 'John Doe' },
                 role: { type: :string, enum: ['member', 'librarian'], example: 'member' }
               }

        let(:user) do
          {
            user: {
              email_address: 'test@example.com',
              password: 'password123',
              password_confirmation: 'password123',
              name: 'Test User',
              role: 'member'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email_address']).to eq('test@example.com')
          expect(data['name']).to eq('Test User')
          expect(data['role']).to eq('member')
        end
      end

      response(422, 'Validation errors') do
        schema type: :object,
               properties: {
                 email_address: { type: :array, items: { type: :string } },
                 password: { type: :array, items: { type: :string } },
                 name: { type: :array, items: { type: :string } },
                 role: { type: :array, items: { type: :string } }
               }

        let(:user) do
          {
            user: {
              email_address: 'invalid-email',
              password: '123',
              password_confirmation: '456',
              name: '',
              role: 'member'  # Use valid role to test other validations
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_present
        end
      end

      response(422, 'Email already taken') do
        schema type: :object,
               properties: {
                 email_address: { type: :array, items: { type: :string } }
               }

        before do
          User.create!(
            email_address: 'existing@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            name: 'Existing User',
            role: 'member'
          )
        end

        let(:user) do
          {
            user: {
              email_address: 'existing@example.com',
              password: 'password123',
              password_confirmation: 'password123',
              name: 'Another User',
              role: 'member'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email_address']).to include('has already been taken')
        end
      end
    end
  end
end
