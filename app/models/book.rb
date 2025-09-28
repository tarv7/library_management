class Book < ApplicationRecord
  has_many :reservations, dependent: :destroy

  enum :genre, %i[ fiction non_fiction mystery science_fiction fantasy romance
    thriller biography history poetry drama ]

  validates :title, presence: true, length: { minimum: 2, maximum: 255 }
  validates :author, presence: true, length: { minimum: 2, maximum: 255 }
  validates :isbn, presence: true, uniqueness: true
  validates :genre, presence: true
  validates :total_copies, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  scope :by_title, ->(title) { where("title ILIKE ?", "%#{title}%") }
  scope :by_author, ->(author) { where("author ILIKE ?", "%#{author}%") }
  scope :by_genre, ->(genre) { where(genre: genre) }
  scope :search, ->(filters) {
    return current_scope if !filters.is_a?(Hash)

    scope = current_scope

    scope = scope.by_title(filters[:title]) if filters[:title].present?
    scope = scope.by_author(filters[:author]) if filters[:author].present?
    scope = scope.by_genre(filters[:genre]) if filters[:genre].present?

    scope
  }

  def available_copies
    total_copies - reservations.not_returned.count
  end
end
