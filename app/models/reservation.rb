class Reservation < ApplicationRecord
  DUE_WITHIN = 2.weeks.freeze
  ALLOWED_SITUATIONS = %w[ not_returned returned overdue due_today ].freeze

  belongs_to :book
  belongs_to :user

  validates :borrowed_on, presence: true
  validate :book_already_borrowed, on: :create
  validate :has_available_copies, on: :create

  scope :not_returned, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :overdue, -> { not_returned.where(due_on: ...Date.current) }
  scope :due_today, -> { not_returned.where(due_on: Date.current) }
  scope :search, ->(filters) {
    return current_scope if !filters.is_a?(Hash)

    scope = current_scope
    scope = scope.where(book_id: filters[:book_id]) if filters[:book_id].present?
    scope = scope.where(user_id: filters[:user_id]) if filters[:user_id].present?
    scope = scope.public_send(filters[:situation]) if ALLOWED_SITUATIONS.include?(filters[:situation])

    scope
  }

  before_create -> { self.due_on = borrowed_on + DUE_WITHIN }

  def return
    update(returned_at: Time.current)
  end

  def status
    if returned_at.present?
      :returned
    elsif due_on < Date.current
      :overdue
    elsif due_on == Date.current
      :due_today
    else
      :not_returned
    end
  end

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
