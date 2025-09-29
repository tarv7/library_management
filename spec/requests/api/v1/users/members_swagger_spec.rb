require 'swagger_helper'

RSpec.describe 'Api::V1::Users::Members', type: :request do
  path '/api/v1/users/members' do
    get('List all members') do
      tags 'Users'
      description 'Returns a list of all members in the system. Only accessible by librarians.'
      produces 'application/json'
      security [ { bearerAuth: [] } ]

      response '200', 'members found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer, example: 1 },
                   name: { type: :string, example: 'Alice Johnson' },
                   email_address: { type: :string, example: 'alice.johnson@example.com' },
                   role: { type: :string, example: 'member', enum: [ 'member' ] },
                   created_at: { type: :string, format: 'date-time', example: '2025-09-18T10:30:00.000Z' },
                   updated_at: { type: :string, format: 'date-time', example: '2025-09-18T10:30:00.000Z' }
                 },
                 required: [ 'id', 'name', 'email_address', 'role', 'created_at', 'updated_at' ]
               }

        let(:librarian) { create(:user, :librarian) }
        let!(:member1) { create(:user, :member, name: "Alice Johnson") }
        let!(:member2) { create(:user, :member, name: "Bob Smith") }
        let(:Authorization) { "Bearer #{JsonWebToken.encode_user(librarian)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.length).to eq(2)
          expect(data.first['role']).to eq('member')
          expect(data.all? { |user| user['role'] == 'member' }).to be_truthy
        end
      end

      response '401', 'unauthorized - member trying to access' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Not Authorized' }
               }

        let(:member) { create(:user, :member) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode_user(member)}" }

        run_test!
      end

      response '401', 'unauthorized - no token' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Not Authorized' }
               }

        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
