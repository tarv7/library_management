class Api::V1::Users::Librarians::DashboardController < Api::V1::BaseController
  before_action :authorized_librarian!

  def show
    @librarian = current_user
    @total_books = Book.count
    @total_borrowed_books = Reservation.not_returned.count
    @books_due_today = Reservation.due_today.includes(:book, :user)
    @members_with_overdue_books = User.with_overdue_books.includes(reservations: :book)

    render :show, status: :ok
  end
end
