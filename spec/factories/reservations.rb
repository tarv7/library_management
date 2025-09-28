FactoryBot.define do
  factory :reservation do
    association :book
    association :user
    borrowed_on { Date.today }
    returned_at { nil }

    trait :returned do
      returned_at { Time.current }
    end

    trait :overdue do
      due_on { Date.today - 2.day }
    end

    trait :future_due do
      due_on { Date.today + 7.days }
    end
  end
end
