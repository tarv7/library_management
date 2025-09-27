require 'rails_helper'

RSpec.describe "/api/v1/books", type: :request do
  let!(:librarian_user) do
    User.create!(
      name: 'Test User',
      email_address: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      role: 'librarian'
    )
  end
  let!(:member_user) do
    User.create!(
      name: 'Member User',
      email_address: 'member@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      role: 'member'
    )
  end

  let(:auth_token) { JsonWebToken.encode(user_id: librarian_user.id) }
  let(:member_auth_token) { JsonWebToken.encode(user_id: member_user.id) }
  let(:valid_attributes) {
    {
      title: "The Great Gatsby",
      author: "F. Scott Fitzgerald",
      genre: 0, # fiction
      isbn: "978-0-7432-7356-5",
      total_copies: 5
    }
  }

  let(:invalid_attributes) {
    {
      title: "",
      author: "",
      genre: nil,
      isbn: "",
      total_copies: -1
    }
  }

  let(:valid_headers) {
    { "Authorization" => "Bearer #{auth_token}" }
  }

  let(:member_valid_headers) {
    { "Authorization" => "Bearer #{member_auth_token}" }
  }

  describe "GET /index" do
    it "renders a successful response" do
      book = Book.create!(valid_attributes)

      get api_v1_books_url, headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.content_type).to match(a_string_including("application/json"))

      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(1)
      expect(json_response.first['title']).to eq('The Great Gatsby')
    end

    it "returns empty array when no books exist" do
      get api_v1_books_url, headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(json_response).to eq([])
    end

    it "allows member users to view books list" do
      Book.create!(valid_attributes)

      get api_v1_books_url, headers: member_valid_headers, as: :json

      expect(response).to be_successful
      expect(json_response).to be_an(Array)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      book = Book.create!(valid_attributes)

      get api_v1_book_url(book), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.content_type).to match(a_string_including("application/json"))

      expect(json_response['id']).to eq(book.id)
      expect(json_response['title']).to eq('The Great Gatsby')
      expect(json_response['author']).to eq('F. Scott Fitzgerald')
      expect(json_response['isbn']).to eq('978-0-7432-7356-5')
    end

    it "returns 404 when book does not exist" do
      get api_v1_book_url(999), headers: valid_headers, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it "allows member users to view individual books" do
      book = Book.create!(valid_attributes)

      get api_v1_book_url(book), headers: member_valid_headers, as: :json

      expect(response).to be_successful
      expect(json_response['id']).to eq(book.id)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Book" do
        expect {
          post api_v1_books_url,
               params: { book: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Book, :count).by(1)
      end

      it "renders a JSON response with the new book" do
        post api_v1_books_url,
             params: { book: valid_attributes }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))

        expect(json_response['title']).to eq('The Great Gatsby')
        expect(json_response['author']).to eq('F. Scott Fitzgerald')
        expect(json_response['genre']).to eq('fiction')
        expect(json_response['isbn']).to eq('978-0-7432-7356-5')
        expect(json_response['total_copies']).to eq(5)
      end

      it "returns unauthorized when member user tries to create a book" do
        post api_v1_books_url,
             params: { book: valid_attributes }, headers: member_valid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Not Authorized')
      end
    end

    context "with invalid parameters" do
      it "does not create a new Book" do
        expect {
          post api_v1_books_url,
               params: { book: invalid_attributes }, headers: valid_headers, as: :json
        }.to change(Book, :count).by(0)
      end

      it "renders a JSON response with errors for the new book" do
        post api_v1_books_url,
             params: { book: invalid_attributes }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))

        expect(json_response["title"]).to eq([ "can't be blank", "is too short (minimum is 2 characters)" ])
        expect(json_response["author"]).to eq([ "can't be blank", "is too short (minimum is 2 characters)" ])
        expect(json_response["isbn"]).to eq([ "can't be blank" ])
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          title: "Updated Title",
          author: "Updated Author",
          total_copies: 10
        }
      }

      it "updates the requested book" do
        book = Book.create!(valid_attributes)

        patch api_v1_book_url(book),
              params: { book: new_attributes }, headers: valid_headers, as: :json
        book.reload

        expect(book.title).to eq("Updated Title")
        expect(book.author).to eq("Updated Author")
        expect(book.total_copies).to eq(10)
      end

      it "renders a JSON response with the book" do
        book = Book.create!(valid_attributes)

        patch api_v1_book_url(book),
              params: { book: new_attributes }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))

        expect(json_response['title']).to eq('Updated Title')
        expect(json_response['author']).to eq('Updated Author')
        expect(json_response['total_copies']).to eq(10)
      end

      it "returns unauthorized when member user tries to update a book" do
        book = Book.create!(valid_attributes)

        patch api_v1_book_url(book),
              params: { book: { title: "Updated Title" } }, headers: member_valid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Not Authorized')
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the book" do
        book = Book.create!(valid_attributes)

        patch api_v1_book_url(book),
              params: { book: invalid_attributes }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))

        expect(json_response["title"]).to eq([ "can't be blank", "is too short (minimum is 2 characters)" ])
        expect(json_response["author"]).to eq([ "can't be blank", "is too short (minimum is 2 characters)" ])
        expect(json_response["isbn"]).to eq([ "can't be blank" ])
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested book" do
      book = Book.create!(valid_attributes)

      expect {
        delete api_v1_book_url(book), headers: valid_headers, as: :json
      }.to change(Book, :count).by(-1)
    end

    it "returns unauthorized when member user tries to delete a book" do
      book = Book.create!(valid_attributes)

      expect {
        delete api_v1_book_url(book), headers: member_valid_headers, as: :json
      }.to change(Book, :count).by(0)

      expect(response).to have_http_status(:unauthorized)
      expect(json_response['error']).to eq('Not Authorized')
    end
  end
end
