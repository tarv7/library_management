class Reservation < ApplicationRecord
  belongs_to :book
  belongs_to :user

  validates :borrowed_on, presence: true
  validate :book_already_borrowed, on: :create
  validate :has_available_copies, on: :create

  scope :not_returned, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :overdue, -> { not_returned.where(due_on: ...Date.today) }

  private

  def book_already_borrowed
    return if Reservation.not_returned.where(book:, user:).none?

    errors.add(:book, "is already borrowed")
  end

  def has_available_copies
    return if book.available_copies.positive?

    errors.add(:book, "has no available copies")
  end
end
