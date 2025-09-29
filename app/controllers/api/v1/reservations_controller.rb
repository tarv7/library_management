class Api::V1::ReservationsController < Api::V1::BaseController
  ALLOWED_SITUATIONS = %w[ not_returned returned overdue due_today ].freeze

  before_action :authorized_librarian!, only: %i[ index ]

  def index
    @all_reservations = Reservation.all
    @reservations = @all_reservations.includes(:book, :user).search(reservation_search_params.to_h)

    render :index, status: :ok
  end

  private

  def reservation_search_params
    params.permit(:book_id, :user_id, :situation)
  end
end
