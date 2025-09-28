class User < ApplicationRecord
  has_secure_password

  has_many :reservations, dependent: :destroy

  enum :role, %i[ member librarian ]

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
end
