require 'swagger_helper'

RSpec.describe 'Api::V1::Reservations', type: :request do
  path '/api/v1/reservations' do
    get('List all reservations') do
      tags 'Reservations'
      description 'Returns a list of all reservations in the system. Only accessible by librarians. Supports filtering by book_id, user_id, and situation.'
      produces 'application/json'

      parameter name: :book_id, in: :query, type: :integer, required: false,
                description: 'Filter reservations by book ID'
      parameter name: :user_id, in: :query, type: :integer, required: false,
                description: 'Filter reservations by user ID'
      parameter name: :situation, in: :query, type: :string, required: false,
                description: 'Filter reservations by status',
                enum: ['not_returned', 'returned', 'overdue', 'due_today']

      security [{ bearerAuth: [] }]

      response '200', 'reservations found' do
        schema type: :object,
               properties: {
                 reservations: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       book_id: { type: :integer, example: 1 },
                       user_id: { type: :integer, example: 2 },
                       borrowed_on: { type: :string, format: :date, example: '2025-09-18' },
                       due_on: { type: :string, format: :date, example: '2025-10-02' },
                       returned_at: { type: :string, format: 'date-time', nullable: true, example: '2025-09-25T10:30:00.000Z' },
                       created_at: { type: :string, format: 'date-time', example: '2025-09-18T10:30:00.000Z' },
                       updated_at: { type: :string, format: 'date-time', example: '2025-09-18T10:30:00.000Z' },
                       book: {
                         type: :object,
                         properties: {
                           id: { type: :integer, example: 1 },
                           title: { type: :string, example: 'To Kill a Mockingbird' },
                           author: { type: :string, example: 'Harper Lee' },
                           isbn: { type: :string, example: '9780061120084' },
                           genre: { type: :string, example: 'fiction' },
                           total_copies: { type: :integer, example: 3 }
                         },
                         required: ['id', 'title', 'author', 'isbn', 'genre', 'total_copies']
                       },
                       user: {
                         type: :object,
                         properties: {
                           id: { type: :integer, example: 2 },
                           name: { type: :string, example: 'John Doe' },
                           email_address: { type: :string, example: 'john.doe@example.com' },
                           role: { type: :string, example: 'member' }
                         },
                         required: ['id', 'name', 'email_address', 'role']
                       },
                       status: { type: :string, enum: ['not_returned', 'returned', 'overdue', 'due_today'], example: 'not_returned' }
                     },
                     required: ['id', 'book_id', 'user_id', 'borrowed_on', 'due_on', 'book', 'user', 'status']
                   }
                 },
                 metadata: {
                   type: :object,
                   properties: {
                     total_count: { type: :integer, example: 15 },
                     filters: {
                       type: :object,
                       properties: {
                         book_id: { type: :string, example: '1' },
                         user_id: { type: :string, example: '2' },
                         situation: { type: :string, example: 'overdue' }
                       }
                     },
                     statistics: {
                       type: :object,
                       properties: {
                         active_count: { type: :integer, example: 8 },
                         returned_count: { type: :integer, example: 5 },
                         overdue_count: { type: :integer, example: 2 },
                         due_today_count: { type: :integer, example: 0 }
                       },
                       required: ['active_count', 'returned_count', 'overdue_count', 'due_today_count']
                     }
                   },
                   required: ['total_count', 'statistics']
                 }
               },
               required: ['reservations', 'metadata']

        let(:librarian) { create(:user, :librarian) }
        let(:member) { create(:user, :member) }
        let(:book) { create(:book) }
        let!(:reservation) { create(:reservation, book: book, user: member) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode_user(librarian)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('reservations')
          expect(data).to have_key('metadata')
          expect(data['reservations']).to be_an(Array)
          expect(data['metadata']).to have_key('total_count')
          expect(data['metadata']).to have_key('statistics')
        end
      end

      response '200', 'filtered reservations by book_id' do
        schema type: :object,
               properties: {
                 reservations: { type: :array },
                 metadata: { type: :object }
               },
               required: ['reservations', 'metadata']

        let(:book) { create(:book) }
        let(:member) { create(:user, :member) }
        let(:librarian) { create(:user, :librarian) }
        let!(:reservation) { create(:reservation, book: book, user: member) }
        let(:book_id) { book.id }
        let(:Authorization) { "Bearer #{JsonWebToken.encode_user(librarian)}" }

        run_test!
      end

      response '200', 'filtered reservations by situation' do
        schema type: :object,
               properties: {
                 reservations: { type: :array },
                 metadata: { type: :object }
               },
               required: ['reservations', 'metadata']

        let(:book) { create(:book) }
        let(:member) { create(:user, :member) }
        let(:librarian) { create(:user, :librarian) }
        let!(:returned_reservation) { create(:reservation, book: book, user: member, borrowed_on: 20.days.ago.to_date, returned_at: 5.days.ago) }
        let(:situation) { 'returned' }
        let(:Authorization) { "Bearer #{JsonWebToken.encode_user(librarian)}" }

        run_test!
      end

      response '401', 'unauthorized - member trying to access' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized access' }
               }

        let(:member) { create(:user, :member) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode_user(member)}" }

        run_test!
      end

      response '401', 'unauthorized - no token' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized access' }
               }

        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
