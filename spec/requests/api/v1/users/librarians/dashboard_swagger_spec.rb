# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Users::Librarians::Dashboard', type: :request do
  let(:member) { create(:user, role: 'member') }
  let(:librarian) { create(:user, role: 'librarian') }
  let(:member_token) { JsonWebToken.encode(user_id: member.id) }
  let(:librarian_token) { JsonWebToken.encode(user_id: librarian.id) }

  path '/api/v1/users/librarians/dashboard' do
    get('Get librarian dashboard') do
      tags 'Librarian Dashboard'
      description 'Retrieves comprehensive dashboard information for librarians including library statistics, books due today, and members with overdue books. Only accessible by librarians.'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      response(200, 'Dashboard data retrieved successfully') do
        schema '$ref' => '#/components/schemas/LibrarianDashboard'

        let(:Authorization) { "Bearer #{librarian_token}" }

        before do
          # Create some books for statistics
          @book1 = create(:book, title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'fiction')
          @book2 = create(:book, title: '1984', author: 'George Orwell', genre: 'science_fiction')
          @book3 = create(:book, title: 'To Kill a Mockingbird', author: 'Harper Lee', genre: 'fiction')

          # Create some members
          @member1 = create(:user, role: 'member', name: 'John Doe', email_address: 'john@example.com')
          @member2 = create(:user, role: 'member', name: 'Alice Johnson', email_address: 'alice@example.com')

          # Create book due today (reservation that expires today)
          create(:reservation,
            book: @book1,
            user: @member1,
            borrowed_on: 14.days.ago.to_date,
            due_on: Date.current
          )

          # Create overdue book (past due date)
          create(:reservation,
            book: @book2,
            user: @member2,
            borrowed_on: 20.days.ago.to_date,
            due_on: 6.days.ago.to_date
          )

          # Create current borrowed book (not due today, not overdue)
          create(:reservation,
            book: @book3,
            user: @member1,
            borrowed_on: 3.days.ago.to_date,
            due_on: 11.days.from_now.to_date
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)

          # Check librarian information
          expect(data['librarian']['id']).to eq(librarian.id)
          expect(data['librarian']['name']).to eq(librarian.name)
          expect(data['librarian']['email_address']).to eq(librarian.email_address)

          # Check statistics
          expect(data['statistics']['total_books']).to eq(3)
          expect(data['statistics']['total_borrowed_books']).to eq(3) # All 3 reservations are not returned
          expect(data['statistics']['books_due_today_count']).to eq(1)
          expect(data['statistics']['members_with_overdue_books_count']).to eq(1)

          # Check books due today structure
          expect(data['books_due_today']).to be_an(Array)
          expect(data['books_due_today'].length).to eq(1)

          due_today = data['books_due_today'].first
          expect(due_today).to have_key('reservation_id')
          expect(due_today).to have_key('borrowed_on')
          expect(due_today).to have_key('due_on')
          expect(due_today['due_on']).to eq(Date.current.to_s)
          expect(due_today['member']).to have_key('id')
          expect(due_today['member']).to have_key('name')
          expect(due_today['member']).to have_key('email_address')
          expect(due_today['book']).to have_key('title')

          # Check members with overdue books structure
          expect(data['members_with_overdue_books']).to be_an(Array)
          expect(data['members_with_overdue_books'].length).to eq(1)

          overdue_member = data['members_with_overdue_books'].first
          expect(overdue_member).to have_key('member_id')
          expect(overdue_member).to have_key('member_name')
          expect(overdue_member).to have_key('member_email')
          expect(overdue_member['overdue_books']).to be_an(Array)
          expect(overdue_member['overdue_books'].length).to eq(1)

          overdue_book = overdue_member['overdue_books'].first
          expect(overdue_book).to have_key('reservation_id')
          expect(overdue_book).to have_key('borrowed_on')
          expect(overdue_book).to have_key('due_on')
          expect(overdue_book).to have_key('days_overdue')
          expect(overdue_book['days_overdue']).to be > 0
          expect(overdue_book['book']).to have_key('title')
        end
      end

      response(200, 'Dashboard with minimal data') do
        schema '$ref' => '#/components/schemas/LibrarianDashboard'

        let(:Authorization) { "Bearer #{librarian_token}" }

        before do
          # Create only one book with no reservations
          create(:book, title: 'Lonely Book', author: 'Solo Author', genre: 'fiction')
        end

        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data['librarian']['id']).to eq(librarian.id)
          expect(data['statistics']['total_books']).to eq(1)
          expect(data['statistics']['total_borrowed_books']).to eq(0)
          expect(data['statistics']['books_due_today_count']).to eq(0)
          expect(data['statistics']['members_with_overdue_books_count']).to eq(0)
          expect(data['books_due_today']).to be_an(Array)
          expect(data['books_due_today']).to be_empty
          expect(data['members_with_overdue_books']).to be_an(Array)
          expect(data['members_with_overdue_books']).to be_empty
        end
      end

      response(401, 'Unauthorized - Only librarians can access dashboard') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{member_token}" }

        run_test!
      end

      response(401, 'Unauthorized - Invalid token') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end

      response(401, 'Unauthorized - Missing token') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
