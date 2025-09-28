class Seeds
  def self.run
    puts "🌱 Starting seeds..."

    create_librarians
    create_members
    create_books
    create_reservations

    print_summary
    puts "✅ Seeds completed successfully!"
  end

  private

  def self.create_librarians
    puts "\n📚 Creating/finding librarians..."

    librarians_data = [
      {
        name: "Thales Lib",
        email_address: "thales.lib@gmail.com",
        password: "password",
        role: :librarian
      },
      {
        name: "Sarah Johnson",
        email_address: "sarah.johnson@library.com",
        password: "password",
        role: :librarian
      }
    ]

    librarians_data.each do |librarian_data|
      librarian = User.find_or_create_by(email_address: librarian_data[:email_address]) do |user|
        user.name = librarian_data[:name]
        user.password = librarian_data[:password]
        user.role = librarian_data[:role]
      end
    end
  end

  def self.create_members
    puts "\n👥 Creating/finding members..."

    members_data = [
      {
        name: "Thales Mem",
        email_address: "thales.mem@gmail.com",
        password: "password",
        role: :member
      },
      {
        name: "John Smith",
        email_address: "john.smith@email.com",
        password: "password",
        role: :member
      },
      {
        name: "Emily Davis",
        email_address: "emily.davis@email.com",
        password: "password",
        role: :member
      },
      {
        name: "Michael Brown",
        email_address: "michael.brown@email.com",
        password: "password",
        role: :member
      },
      {
        name: "Jessica Wilson",
        email_address: "jessica.wilson@email.com",
        password: "password",
        role: :member
      }
    ]

    members_data.each do |member_data|
      member = User.find_or_create_by(email_address: member_data[:email_address]) do |user|
        user.name = member_data[:name]
        user.password = member_data[:password]
        user.role = member_data[:role]
      end
    end
  end

  def self.create_books
    puts "\n📖 Creating/finding books..."
    books_data = [
      {
        title: "To Kill a Mockingbird",
        author: "Harper Lee",
        genre: :fiction,
        isbn: "9780061120084",
        total_copies: 3
      },
      {
        title: "1984",
        author: "George Orwell",
        genre: :science_fiction,
        isbn: "9780451524935",
        total_copies: 4
      },
      {
        title: "Pride and Prejudice",
        author: "Jane Austen",
        genre: :romance,
        isbn: "9780141439518",
        total_copies: 3
      },
      {
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        genre: :fiction,
        isbn: "9780743273565",
        total_copies: 2
      },
      {
        title: "The Hobbit",
        author: "J.R.R. Tolkien",
        genre: :fantasy,
        isbn: "9780547928227",
        total_copies: 3
      },
      {
        title: "Harry Potter and the Philosopher's Stone",
        author: "J.K. Rowling",
        genre: :fantasy,
        isbn: "9780747532699",
        total_copies: 4
      },
      {
        title: "The Da Vinci Code",
        author: "Dan Brown",
        genre: :thriller,
        isbn: "9780307474278",
        total_copies: 2
      },
      {
        title: "Steve Jobs",
        author: "Walter Isaacson",
        genre: :biography,
        isbn: "9781451648539",
        total_copies: 2
      },
      {
        title: "The Catcher in the Rye",
        author: "J.D. Salinger",
        genre: :fiction,
        isbn: "9780316769174",
        total_copies: 3
      },
      {
        title: "Sherlock Holmes: The Hound of the Baskervilles",
        author: "Arthur Conan Doyle",
        genre: :mystery,
        isbn: "9780486282145",
        total_copies: 2
      },
      {
        title: "One Hundred Years of Solitude",
        author: "Gabriel García Márquez",
        genre: :fiction,
        isbn: "9780060883287",
        total_copies: 3
      },
      {
        title: "The Little Prince",
        author: "Antoine de Saint-Exupéry",
        genre: :fiction,
        isbn: "9780156012195",
        total_copies: 4
      },
      {
        title: "Dracula",
        author: "Bram Stoker",
        genre: :thriller,
        isbn: "9780486411095",
        total_copies: 2
      },
      {
        title: "The Chronicles of Narnia: The Lion, the Witch and the Wardrobe",
        author: "C.S. Lewis",
        genre: :fantasy,
        isbn: "9780064471046",
        total_copies: 3
      },
      {
        title: "The Lord of the Rings: The Fellowship of the Ring",
        author: "J.R.R. Tolkien",
        genre: :fantasy,
        isbn: "9780547928210",
        total_copies: 2
      },
      {
        title: "Crime and Punishment",
        author: "Fyodor Dostoevsky",
        genre: :fiction,
        isbn: "9780486454115",
        total_copies: 2
      },
      {
        title: "The Alchemist",
        author: "Paulo Coelho",
        genre: :fiction,
        isbn: "9780061122415",
        total_copies: 3
      },
      {
        title: "Hamlet",
        author: "William Shakespeare",
        genre: :drama,
        isbn: "9780486272788",
        total_copies: 2
      },
      {
        title: "Sapiens: A Brief History of Humankind",
        author: "Yuval Noah Harari",
        genre: :history,
        isbn: "9780062316097",
        total_copies: 3
      },
      {
        title: "Cosmos",
        author: "Carl Sagan",
        genre: :non_fiction,
        isbn: "9780345331359",
        total_copies: 2
      }
    ]

    books_data.each do |book_data|
      book = Book.find_or_create_by(isbn: book_data[:isbn]) do |b|
        b.title = book_data[:title]
        b.author = book_data[:author]
        b.genre = book_data[:genre]
        b.total_copies = book_data[:total_copies]
      end
    end
  end

  def self.create_reservations
    puts "\n🔖 Creating/finding reservations..."

    members = User.member
    books = Book.all

    reservations_data = [
      # Current not returned reservations
      {
        user: members[0],
        book: books[0],
        borrowed_on: 10.days.ago.to_date,
        returned_at: nil
      },
      {
        user: members[1],
        book: books[2],
        borrowed_on: 5.days.ago.to_date,
        returned_at: nil
      },
      {
        user: members[2],
        book: books[4],
        borrowed_on: 3.days.ago.to_date,
        returned_at: nil
      },
      {
        user: members[3],
        book: books[6],
        borrowed_on: 7.days.ago.to_date,
        returned_at: nil
      },
      {
        user: members[4],
        book: books[8],
        borrowed_on: 1.day.ago.to_date,
        returned_at: nil
      },
      # Overdue reservation (borrowed more than 2 weeks ago)
      {
        user: members[0],
        book: books[10],
        borrowed_on: 20.days.ago.to_date,
        returned_at: nil
      },
      {
        user: members[0],
        book: books[9],
        borrowed_on: 15.days.ago.to_date,
        returned_at: nil
      },
      {
        user: members[1],
        book: books[11],
        borrowed_on: 18.days.ago.to_date,
        returned_at: nil
      },
      # Returned reservations
      {
        user: members[1],
        book: books[1],
        borrowed_on: 25.days.ago.to_date,
        returned_at: 10.days.ago
      },
      {
        user: members[2],
        book: books[3],
        borrowed_on: 30.days.ago.to_date,
        returned_at: 15.days.ago
      },
      {
        user: members[3],
        book: books[5],
        borrowed_on: 35.days.ago.to_date,
        returned_at: 20.days.ago
      },
      {
        user: members[4],
        book: books[7],
        borrowed_on: 40.days.ago.to_date,
        returned_at: 25.days.ago
      }
    ]

    reservations_data.each do |reservation_data|
      # Use a combination of user, book, and borrowed_on to identify unique reservations
      reservation = Reservation.find_or_create_by(
        user: reservation_data[:user],
        book: reservation_data[:book],
        borrowed_on: reservation_data[:borrowed_on]
      ) do |r|
        r.returned_at = reservation_data[:returned_at]
      end
    end
  end

  def self.print_summary
    puts "\n📊 === Summary ==="
    puts "📚 #{User.librarian.count} librarians"
    puts "👥 #{User.member.count} members"
    puts "📖 #{Book.count} books"
    puts "🔖 #{Reservation.count} reservations (#{Reservation.not_returned.count} active, #{Reservation.returned.count} returned)"
    puts "⚠️  #{Reservation.overdue.count} overdue reservations"
  end
end

# Run the seeds
Seeds.run
