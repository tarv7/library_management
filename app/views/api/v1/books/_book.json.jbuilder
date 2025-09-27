json.extract! book, :id, :title, :author, :genre, :isbn, :total_copies, :created_at, :updated_at
json.url api_v1_book_url(book, format: :json)
