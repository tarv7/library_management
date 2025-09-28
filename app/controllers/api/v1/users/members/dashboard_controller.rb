class Api::V1::Users::Members::DashboardController < Api::V1::BaseController
  before_action :authorized_member!

  def show
    @member = current_user
    @borrowed_books = current_user.reservations.not_returned.includes(:book)
    @overdue_books = current_user.reservations.overdue.includes(:book)

    render :show, status: :ok
  end
end
