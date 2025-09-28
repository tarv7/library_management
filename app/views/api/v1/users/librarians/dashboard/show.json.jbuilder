json.librarian do
  json.extract! @librarian, :id, :name, :email_address
end

json.statistics do
  json.total_books @total_books
  json.total_borrowed_books @total_borrowed_books
  json.books_due_today_count @books_due_today.count
  json.members_with_overdue_books_count @members_with_overdue_books.count
end

json.books_due_today @books_due_today do |reservation|
  json.reservation_id reservation.id
  json.borrowed_on reservation.borrowed_on
  json.due_on reservation.due_on
  json.member do
    json.extract! reservation.user, :id, :name, :email_address
  end
  json.book do
    json.extract! reservation.book, :id, :title, :author, :isbn, :genre
  end
end

json.members_with_overdue_books @members_with_overdue_books do |member|
  json.member_id member.id
  json.member_name member.name
  json.member_email member.email_address

  overdue_reservations = member.reservations.overdue.includes(:book)
  json.overdue_books overdue_reservations do |reservation|
    json.reservation_id reservation.id
    json.borrowed_on reservation.borrowed_on
    json.due_on reservation.due_on
    json.days_overdue (Date.current - reservation.due_on).to_i
    json.book do
      json.extract! reservation.book, :id, :title, :author, :isbn, :genre
    end
  end
end
