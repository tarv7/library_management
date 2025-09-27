class Book < ApplicationRecord
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
end
