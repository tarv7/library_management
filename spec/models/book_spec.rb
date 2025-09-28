require "rails_helper"

RSpec.describe Book, type: :model do
  let(:valid_attributes) do
    {
      title: "The Great Gatsby",
      author: "F. Scott Fitzgerald",
      genre: "fiction",
      isbn: "978-0-7432-7356-5",
      total_copies: 5
    }
  end

  describe "validations" do
    subject { Book.new(valid_attributes) }

    describe "title" do
      it "is required" do
        subject.title = nil

        expect(subject).not_to be_valid
        expect(subject.errors[:title]).to include("can't be blank")
      end

      it "is required to not be empty" do
        subject.title = ""

        expect(subject).not_to be_valid
        expect(subject.errors[:title]).to include("can't be blank")
      end

      it "must be at least 2 characters long" do
        subject.title = "A"

        expect(subject).not_to be_valid
        expect(subject.errors[:title]).to include("is too short (minimum is 2 characters)")
      end

      it "can be exactly 2 characters long" do
        subject.title = "Ab"

        expect(subject).to be_valid
      end

      it "cannot be longer than 255 characters" do
        subject.title = "a" * 256

        expect(subject).not_to be_valid
        expect(subject.errors[:title]).to include("is too long (maximum is 255 characters)")
      end

      it "can be exactly 255 characters long" do
        subject.title = "a" * 255

        expect(subject).to be_valid
      end
    end

    describe "author" do
      it "is required" do
        subject.author = nil

        expect(subject).not_to be_valid
        expect(subject.errors[:author]).to include("can't be blank")
      end

      it "is required to not be empty" do
        subject.author = ""

        expect(subject).not_to be_valid
        expect(subject.errors[:author]).to include("can't be blank")
      end

      it "must be at least 2 characters long" do
        subject.author = "A"

        expect(subject).not_to be_valid
        expect(subject.errors[:author]).to include("is too short (minimum is 2 characters)")
      end

      it "can be exactly 2 characters long" do
        subject.author = "Ab"

        expect(subject).to be_valid
      end

      it "cannot be longer than 255 characters" do
        subject.author = "a" * 256

        expect(subject).not_to be_valid
        expect(subject.errors[:author]).to include("is too long (maximum is 255 characters)")
      end

      it "can be exactly 255 characters long" do
        subject.author = "a" * 255

        expect(subject).to be_valid
      end
    end

    describe "isbn" do
      it "is required" do
        subject.isbn = nil

        expect(subject).not_to be_valid
        expect(subject.errors[:isbn]).to include("can't be blank")
      end

      it "is required to not be empty" do
        subject.isbn = ""

        expect(subject).not_to be_valid
        expect(subject.errors[:isbn]).to include("can't be blank")
      end

      it "must be unique" do
        Book.create!(valid_attributes)

        expect(subject).not_to be_valid
        expect(subject.errors[:isbn]).to include("has already been taken")
      end
    end

    describe "genre" do
      it "is required" do
        subject.genre = nil

        expect(subject).not_to be_valid
        expect(subject.errors[:genre]).to include("can't be blank")
      end

      it "accepts valid genre values" do
        Book.genres.keys.each do |genre|
          subject.genre = genre

          expect(subject).to be_valid, "Expected #{genre} to be valid"
        end
      end

      it "rejects invalid genre values" do
        expect {
          subject.genre = "invalid_genre"
        }.to raise_error(ArgumentError, "'invalid_genre' is not a valid genre")
      end
    end

    describe "total_copies" do
      it "is required" do
        subject.total_copies = nil

        expect(subject).not_to be_valid
        expect(subject.errors[:total_copies]).to include("can't be blank")
      end

      it "must be an integer" do
        subject.total_copies = 1.5

        expect(subject).not_to be_valid
        expect(subject.errors[:total_copies]).to include("must be an integer")
      end

      it "can be zero" do
        subject.total_copies = 0

        expect(subject).to be_valid
      end

      it "can be positive" do
        subject.total_copies = 10

        expect(subject).to be_valid
      end

      it "cannot be negative" do
        subject.total_copies = -1

        expect(subject).not_to be_valid
        expect(subject.errors[:total_copies]).to include("must be greater than or equal to 0")
      end
    end
  end

  describe "enums" do
    describe "genre" do
      it "defines all expected genre values" do
        expected_genres = %w[fiction non_fiction mystery science_fiction fantasy romance thriller biography history poetry drama]

        expect(Book.genres.keys).to match_array(expected_genres)
      end

      it "assigns correct integer values to genres" do
        expect(Book.genres["fiction"]).to eq(0)
        expect(Book.genres["non_fiction"]).to eq(1)
        expect(Book.genres["mystery"]).to eq(2)
        expect(Book.genres["science_fiction"]).to eq(3)
        expect(Book.genres["fantasy"]).to eq(4)
        expect(Book.genres["romance"]).to eq(5)
        expect(Book.genres["thriller"]).to eq(6)
        expect(Book.genres["biography"]).to eq(7)
        expect(Book.genres["history"]).to eq(8)
        expect(Book.genres["poetry"]).to eq(9)
        expect(Book.genres["drama"]).to eq(10)
      end

      it "provides helper methods for each genre" do
        book = Book.new(valid_attributes.merge(genre: "fiction"))
        expect(book.fiction?).to be true
        expect(book.mystery?).to be false

        book.genre = "mystery"
        expect(book.fiction?).to be false
        expect(book.mystery?).to be true
      end

      it "provides scope methods for each genre" do
        fiction_book = Book.create!(valid_attributes.merge(isbn: "123-456-789-0"))
        mystery_book = Book.create!(valid_attributes.merge(genre: "mystery", isbn: "123-456-789-1"))

        expect(Book.fiction).to include(fiction_book)
        expect(Book.fiction).not_to include(mystery_book)

        expect(Book.mystery).to include(mystery_book)
        expect(Book.mystery).not_to include(fiction_book)
      end
    end
  end

  describe "scopes" do
    let!(:unique_book_1) { create(:book, title: "Unique Title", author: "Unique Author", genre: :romance, isbn: "978-0-123-45678-9", total_copies: 4) }
    before do
      create_list(:book, 3, :fiction)
      create_list(:book, 2, :mystery)
    end

    it "filters by title" do
      results = Book.by_title(unique_book_1.title)

      expect(results.count).to eq(1)
      expect(results.first).to eq(unique_book_1)
    end

    it "filters by author" do
      results = Book.by_author(unique_book_1.author)

      expect(results.count).to eq(1)
      expect(results.first).to eq(unique_book_1)
    end

    it "filters by genre" do
      results = Book.by_genre("romance")

      expect(results.count).to eq(1)
      expect(results.first).to eq(unique_book_1)
    end

    describe "search" do
      it "filters by title" do
        results = Book.all.search(title: unique_book_1.title)

        expect(results.count).to eq(1)
        expect(results.first).to eq(unique_book_1)
      end

      it "filters by author" do
        results = Book.all.search(author: unique_book_1.author)

        expect(results.count).to eq(1)
        expect(results.first).to eq(unique_book_1)
      end

      it "filters by genre" do
        results = Book.all.search(genre: "mystery")

        expect(results.count).to eq(2)
        expect(results.pluck(:genre).uniq).to eq([ "mystery" ])
      end

      it "filters by title and author" do
        results = Book.all.search(title: unique_book_1.title, author: unique_book_1.author)

        expect(results.count).to eq(1)
        expect(results.first).to eq(unique_book_1)
      end

      it "returns all books when no filters are provided" do
        results = Book.all.search({})

        expect(results.count).to eq(6) # 3 fiction + 2 mystery + 1 unique romance
      end

      it "returns all books when filters are nil" do
        results = Book.all.search(nil)

        expect(results.count).to eq(6) # 3 fiction + 2 mystery + 1 unique romance
      end

      it "returns no books when no matches are found" do
        results = Book.all.search(title: "Nonexistent Title")

        expect(results.count).to eq(0)
      end
    end
  end

  describe "#available_copies" do
    let(:book) { create(:book, total_copies: 5) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    context "when no reservations exist" do
      it "returns the total number of copies" do
        expect(book.available_copies).to eq(5)
      end
    end

    context "when there are active (not returned) reservations" do
      before do
        create(:reservation, book: book, user: user1, returned_at: nil)
        create(:reservation, book: book, user: user2, returned_at: nil)
      end

      it "subtracts active reservations from total copies" do
        expect(book.available_copies).to eq(3)
      end
    end

    context "when there are returned reservations" do
      before do
        create(:reservation, book: book, user: user1, returned_at: Time.current)
        create(:reservation, book: book, user: user2, returned_at: Time.current)
      end

      it "does not count returned reservations" do
        expect(book.available_copies).to eq(5)
      end
    end

    context "when all copies are reserved" do
      before do
        5.times do |i|
          user = create(:user)
          create(:reservation, book: book, user: user, returned_at: nil)
        end
      end

      it "returns zero available copies" do
        expect(book.available_copies).to eq(0)
      end
    end
  end
end
