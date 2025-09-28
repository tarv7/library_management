class Api::V1::Books::ReservationsController < Api::V1::BaseController
  before_action :authorized_member!, only: %i[ create ]
  before_action :authorized_librarian!, only: %i[ update ]
  before_action :set_book, only: %i[ create ]
  before_action :set_reservation, only: %i[ update ]

  def create
    @reservation = Reservation.new(book: @book, user: current_user, borrowed_on: Date.today)

    if @reservation.save
      render :show, status: :created
    else
      render json: @reservation.errors, status: :unprocessable_content
    end
  end

  def update
    if @reservation.return
      render :show, status: :ok
    else
      render json: @reservation.errors, status: :unprocessable_content
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end
end
