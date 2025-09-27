FactoryBot.define do
  factory :book do
    title { "The Great Gatsby" }
    author { "F. Scott Fitzgerald" }
    genre { :fiction }
    total_copies { 5 }

    # Sequence for unique ISBNs when creating multiple books
    sequence :isbn do |n|
      "978-#{SecureRandom.random_number(10000).to_s.rjust(4, '0')}-#{SecureRandom.random_number(100000).to_s.rjust(5, '0')}-#{n}"
    end

    trait :non_fiction do
      title { "Sapiens: A Brief History of Humankind" }
      author { "Yuval Noah Harari" }
      genre { :non_fiction }
    end

    trait :mystery do
      title { "The Girl with the Dragon Tattoo" }
      author { "Stieg Larsson" }
      genre { :mystery }
    end

    trait :science_fiction do
      title { "Dune" }
      author { "Frank Herbert" }
      genre { :science_fiction }
    end

    trait :fantasy do
      title { "The Lord of the Rings" }
      author { "J.R.R. Tolkien" }
      genre { :fantasy }
    end

    trait :romance do
      title { "Pride and Prejudice" }
      author { "Jane Austen" }
      genre { :romance }
    end

    trait :thriller do
      title { "The Da Vinci Code" }
      author { "Dan Brown" }
      genre { :thriller }
    end

    trait :biography do
      title { "Steve Jobs" }
      author { "Walter Isaacson" }
      genre { :biography }
    end

    trait :history do
      title { "A People's History of the United States" }
      author { "Howard Zinn" }
      genre { :history }
    end

    trait :poetry do
      title { "Leaves of Grass" }
      author { "Walt Whitman" }
      genre { :poetry }
    end

    trait :drama do
      title { "Hamlet" }
      author { "William Shakespeare" }
      genre { :drama }
    end

    trait :zero_copies do
      total_copies { 0 }
    end

    trait :many_copies do
      total_copies { 50 }
    end
  end
end
