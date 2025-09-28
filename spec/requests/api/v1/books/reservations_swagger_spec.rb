# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Books::Reservations', type: :request do
  let(:member) { create(:user, role: 'member') }
  let(:librarian) { create(:user, role: 'librarian') }
  let(:member_token) { JsonWebToken.encode_user(member) }
  let(:librarian_token) { JsonWebToken.encode_user(librarian) }

  path '/api/v1/books/{book_id}/reservations' do
    parameter name: 'book_id', in: :path, type: :integer, description: 'Book ID'

    post('Create a book reservation') do
      tags 'Reservations'
      description 'Creates a new reservation for a book. Only members can create reservations. Each member can only have one active reservation per book.'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      response(201, 'Reservation created successfully') do
        schema '$ref' => '#/components/schemas/Reservation'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:book_record) { create(:book, total_copies: 5) }
        let(:book_id) { book_record.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['book_id']).to eq(book_record.id)
          expect(data['user_id']).to eq(member.id)
          expect(data['borrowed_on']).to eq(Date.today.to_s)
          expect(data['returned_at']).to be_nil
        end
      end

      response(401, 'Unauthorized - Only members can create reservations') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{librarian_token}" }
        let(:book_record) { create(:book) }
        let(:book_id) { book_record.id }

        run_test!
      end

      response(422, 'Book already borrowed by user') do
        schema '$ref' => '#/components/schemas/ReservationError'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:book_record) { create(:book, total_copies: 5) }
        let(:book_id) { book_record.id }

        before do
          # Create an existing reservation for the same user and book
          create(:reservation, book: book_record, user: member, borrowed_on: Date.today)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['book']).to include('is already borrowed')
        end
      end

      response(422, 'No available copies') do
        schema '$ref' => '#/components/schemas/ReservationError'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:book_record) { create(:book, total_copies: 1) }
        let(:book_id) { book_record.id }

        before do
          # Create reservations for all available copies
          other_user = create(:user, role: 'member')
          create(:reservation, book: book_record, user: other_user, borrowed_on: Date.today)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['book']).to include('has no available copies')
        end
      end

      response(404, 'Book not found') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:book_id) { 999999 }

        run_test!
      end

      response(401, 'Unauthorized - Invalid token') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:book_record) { create(:book) }
        let(:book_id) { book_record.id }

        run_test!
      end
    end
  end

  path '/api/v1/books/{book_id}/reservations/{id}' do
    parameter name: 'book_id', in: :path, type: :integer, description: 'Book ID'
    parameter name: 'id', in: :path, type: :integer, description: 'Reservation ID'

    put('Return a reserved book') do
      tags 'Reservations'
      description 'Marks a reservation as returned. Only librarians can perform this action.'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      response(200, 'Book returned successfully') do
        schema '$ref' => '#/components/schemas/Reservation'

        let(:Authorization) { "Bearer #{librarian_token}" }
        let(:book_record) { create(:book) }
        let(:book_id) { book_record.id }
        let(:reservation_record) { create(:reservation, book: book_record, user: member) }
        let(:id) { reservation_record.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(reservation_record.id)
          expect(data['returned_at']).to be_present
        end
      end

      response(401, 'Unauthorized - Only librarians can return books') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:book_record) { create(:book) }
        let(:book_id) { book_record.id }
        let(:reservation_record) { create(:reservation, book: book_record, user: member) }
        let(:id) { reservation_record.id }

        run_test!
      end

      response(404, 'Reservation not found') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{librarian_token}" }
        let(:book_record) { create(:book) }
        let(:book_id) { book_record.id }
        let(:id) { 999999 }

        run_test!
      end



      response(401, 'Unauthorized - Invalid token') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:book_record) { create(:book) }
        let(:book_id) { book_record.id }
        let(:reservation_record) { create(:reservation, book: book_record, user: member) }
        let(:id) { reservation_record.id }

        run_test!
      end
    end
  end
end
