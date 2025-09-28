# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Users::Members::Dashboard', type: :request do
  let(:member) { create(:user, role: 'member') }
  let(:librarian) { create(:user, role: 'librarian') }
  let(:member_token) { JsonWebToken.encode_user(member) }
  let(:librarian_token) { JsonWebToken.encode_user(librarian) }

  path '/api/v1/users/members/dashboard' do
    get('Get member dashboard') do
      tags 'Member Dashboard'
      description 'Retrieves dashboard information for a member including borrowed books, overdue books, and summary statistics. Only accessible by members.'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      response(200, 'Dashboard data retrieved successfully') do
        schema '$ref' => '#/components/schemas/MemberDashboard'

        let(:Authorization) { "Bearer #{member_token}" }

        before do
          # Create some books
          @book1 = create(:book, title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'fiction')
          @book2 = create(:book, title: '1984', author: 'George Orwell', genre: 'science_fiction')
          @book3 = create(:book, title: 'To Kill a Mockingbird', author: 'Harper Lee', genre: 'fiction')

          # Create current borrowed books (not overdue)
          create(:reservation,
            book: @book1,
            user: member,
            borrowed_on: 5.days.ago.to_date,
            due_on: 9.days.from_now.to_date
          )

          # Create overdue book
          create(:reservation,
            book: @book2,
            user: member,
            borrowed_on: 20.days.ago.to_date,
            due_on: 6.days.ago.to_date
          )

          # Create another current borrowed book
          create(:reservation,
            book: @book3,
            user: member,
            borrowed_on: 3.days.ago.to_date,
            due_on: 11.days.from_now.to_date
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)

          # Check member information
          expect(data['member']['id']).to eq(member.id)
          expect(data['member']['name']).to eq(member.name)
          expect(data['member']['email_address']).to eq(member.email_address)

          # Check borrowed books (should include all 3 books - current and overdue)
          expect(data['borrowed_books']).to be_an(Array)
          expect(data['borrowed_books'].length).to eq(3)

          # Check overdue books (should be 1)
          expect(data['overdue_books']).to be_an(Array)
          expect(data['overdue_books'].length).to eq(1)
          expect(data['overdue_books'][0]['days_overdue']).to be > 0

          # Check summary
          expect(data['summary']['total_borrowed_books']).to eq(3)
          expect(data['summary']['total_overdue_books']).to eq(1)

          # Verify book structure
          borrowed_book = data['borrowed_books'].first
          expect(borrowed_book).to have_key('reservation_id')
          expect(borrowed_book).to have_key('borrowed_on')
          expect(borrowed_book).to have_key('due_on')
          expect(borrowed_book['book']).to have_key('id')
          expect(borrowed_book['book']).to have_key('title')
          expect(borrowed_book['book']).to have_key('author')
          expect(borrowed_book['book']).to have_key('isbn')
          expect(borrowed_book['book']).to have_key('genre')
        end
      end

      response(200, 'Dashboard with no borrowed books') do
        schema '$ref' => '#/components/schemas/MemberDashboard'

        let(:Authorization) { "Bearer #{member_token}" }

        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data['member']['id']).to eq(member.id)
          expect(data['borrowed_books']).to be_an(Array)
          expect(data['borrowed_books']).to be_empty
          expect(data['overdue_books']).to be_an(Array)
          expect(data['overdue_books']).to be_empty
          expect(data['summary']['total_borrowed_books']).to eq(0)
          expect(data['summary']['total_overdue_books']).to eq(0)
        end
      end

      response(401, 'Unauthorized - Only members can access dashboard') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{librarian_token}" }

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
