class Api::V1::BooksController < Api::V1::BaseController
  before_action :set_book, only: %i[ show update destroy ]

  def index
    @books = Book.all
  end

  def show
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      render :show, status: :created
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      render :show, status: :ok
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy!
  end

  private

  def set_book
    @book = Book.find(params.expect(:id))
  end

  def book_params
    params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
  end
end
