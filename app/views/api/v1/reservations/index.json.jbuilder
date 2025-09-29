json.reservations @reservations do |reservation|
  json.extract! reservation, :id, :book_id, :user_id, :borrowed_on, :due_on, :returned_at, :status, :created_at, :updated_at

  json.book do
    json.extract! reservation.book, :id, :title, :author, :isbn, :genre, :total_copies
  end

  json.user do
    json.extract! reservation.user, :id, :name, :email_address, :role
  end
end

json.metadata do
  json.total_count @reservations.count
  json.filters do
    json.book_id params[:book_id] if params[:book_id].present?
    json.user_id params[:user_id] if params[:user_id].present?
    json.situation params[:situation] if params[:situation].present?
  end
  json.statistics do
    json.active_count @all_reservations.not_returned.count
    json.returned_count @all_reservations.returned.count
    json.overdue_count @all_reservations.overdue.count
    json.due_today_count @all_reservations.due_today.count
  end
end
