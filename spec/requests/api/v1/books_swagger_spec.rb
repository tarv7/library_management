# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Books', type: :request do
  let(:user) { create(:user, role: 'member') }
  let(:librarian) { create(:user, role: 'librarian') }
  let(:member_token) { JsonWebToken.encode(user_id: user.id) }
  let(:librarian_token) { JsonWebToken.encode(user_id: librarian.id) }

  path '/api/v1/books' do
    get('List all books') do
      tags 'Books'
      description 'Retrieves a list of all books. Supports search filters for title, author, and genre.'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      parameter name: :title, in: :query, type: :string, required: false, description: 'Filter by book title (partial match)'
      parameter name: :author, in: :query, type: :string, required: false, description: 'Filter by author name (partial match)'
      parameter name: :genre, in: :query, type: :string, required: false, description: 'Filter by genre', enum: ['fiction', 'non_fiction', 'mystery', 'science_fiction', 'fantasy', 'romance', 'thriller', 'biography', 'history', 'poetry', 'drama']

      response(200, 'Books retrieved successfully') do
        schema '$ref' => '#/components/schemas/BooksArray'

        let(:Authorization) { "Bearer #{member_token}" }

        before do
          create(:book, title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'fiction')
          create(:book, title: '1984', author: 'George Orwell', genre: 'science_fiction')
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.length).to eq(2)
        end
      end

      response(401, 'Unauthorized') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end

    post('Create a new book') do
      tags 'Books'
      description 'Creates a new book in the library. Only librarians can create books.'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      parameter name: :book, in: :body, schema: {
        type: :object,
        properties: {
          book: {
            '$ref' => '#/components/schemas/BookInput'
          }
        },
        required: ['book']
      }

      response(201, 'Book created successfully') do
        schema '$ref' => '#/components/schemas/Book'

        let(:Authorization) { "Bearer #{librarian_token}" }
        let(:book) do
          {
            book: {
              title: 'New Book',
              author: 'New Author',
              genre: 'fiction',
              isbn: '978-1-23456-789-0',
              total_copies: 3
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('New Book')
          expect(data['author']).to eq('New Author')
        end
      end

      response(401, 'Unauthorized - Only librarians can create books') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:book) do
          {
            book: {
              title: 'New Book',
              author: 'New Author',
              genre: 'fiction',
              isbn: '978-1-23456-789-0',
              total_copies: 3
            }
          }
        end

        run_test!
      end

      response(422, 'Validation errors') do
        schema type: :object

        let(:Authorization) { "Bearer #{librarian_token}" }
        let(:book) do
          {
            book: {
              title: '',
              author: '',
              genre: 'fiction',  # Use valid genre to test other validations
              isbn: '',
              total_copies: -1
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/books/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Book ID'

    get('Show a book') do
      tags 'Books'
      description 'Retrieves details of a specific book'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      response(200, 'Book found') do
        schema '$ref' => '#/components/schemas/Book'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:book_record) { create(:book) }
        let(:id) { book_record.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(book_record.id)
        end
      end

      response(404, 'Book not found') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:id) { 999999 }

        run_test!
      end
    end

    put('Update a book') do
      tags 'Books'
      description 'Updates a book. Only librarians can update books.'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      parameter name: :book, in: :body, schema: {
        type: :object,
        properties: {
          book: {
            '$ref' => '#/components/schemas/BookInput'
          }
        },
        required: ['book']
      }

      response(200, 'Book updated successfully') do
        schema '$ref' => '#/components/schemas/Book'

        let(:Authorization) { "Bearer #{librarian_token}" }
        let(:book_record) { create(:book) }
        let(:id) { book_record.id }
        let(:book) do
          {
            book: {
              title: 'Updated Title',
              author: book_record.author,
              genre: book_record.genre,
              isbn: book_record.isbn,
              total_copies: book_record.total_copies
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('Updated Title')
        end
      end

      response(401, 'Unauthorized - Only librarians can update books') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:book_record) { create(:book) }
        let(:id) { book_record.id }
        let(:book) do
          {
            book: {
              title: 'Updated Title'
            }
          }
        end

        run_test!
      end
    end

    delete('Delete a book') do
      tags 'Books'
      description 'Deletes a book from the library. Only librarians can delete books.'
      security [{ bearerAuth: [] }]

      response(204, 'Book deleted successfully') do
        let(:Authorization) { "Bearer #{librarian_token}" }
        let(:book_record) { create(:book) }
        let(:id) { book_record.id }

        run_test!
      end

      response(401, 'Unauthorized - Only librarians can delete books') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{member_token}" }
        let(:book_record) { create(:book) }
        let(:id) { book_record.id }

        run_test!
      end
    end
  end
end
