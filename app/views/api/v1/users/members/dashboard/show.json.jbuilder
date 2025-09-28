json.member do
  json.extract! @member, :id, :name, :email_address
end

json.borrowed_books @borrowed_books do |reservation|
  json.reservation_id reservation.id
  json.borrowed_on reservation.borrowed_on
  json.due_on reservation.due_on
  json.book do
    json.extract! reservation.book, :id, :title, :author, :isbn, :genre
  end
end

json.overdue_books @overdue_books do |reservation|
  json.reservation_id reservation.id
  json.borrowed_on reservation.borrowed_on
  json.due_on reservation.due_on
  json.days_overdue (Date.current - reservation.due_on).to_i
  json.book do
    json.extract! reservation.book, :id, :title, :author, :isbn, :genre
  end
end

json.summary do
  json.total_borrowed_books @borrowed_books.count
  json.total_overdue_books @overdue_books.count
end
