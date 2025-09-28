require "rails_helper"

RSpec.describe Reservation, type: :model do
  describe "associations" do
    it "belongs to book" do
      expect(Reservation.new).to respond_to(:book)
      expect(Reservation.new).to respond_to(:book=)
    end

    it "belongs to user" do
      expect(Reservation.new).to respond_to(:user)
      expect(Reservation.new).to respond_to(:user=)
    end
  end

  describe "validations" do
    it "validates presence of borrowed_on" do
      reservation = build(:reservation, borrowed_on: nil)

      expect(reservation).not_to be_valid
      expect(reservation.errors[:borrowed_on]).to include("can't be blank")
    end

    describe "book_already_borrowed validation" do
      let(:book) { create(:book) }
      let(:user) { create(:user) }

      context "when user doesn't have an active reservation for the book" do
        it "allows creating a new reservation" do
          reservation = build(:reservation, book: book, user: user)

          expect(reservation).to be_valid
        end
      end

      context "when user already has an active reservation for the book" do
        before do
          create(:reservation, book: book, user: user, returned_at: nil)
        end

        it "prevents creating another reservation" do
          new_reservation = build(:reservation, book: book, user: user)

          expect(new_reservation).not_to be_valid
          expect(new_reservation.errors[:book]).to include("is already borrowed")
        end
      end

      context "when user had a reservation but returned the book" do
        before do
          create(:reservation, :returned, book: book, user: user)
        end

        it "allows creating a new reservation" do
          new_reservation = build(:reservation, book: book, user: user)

          expect(new_reservation).to be_valid
        end
      end

      it "allows borrowing again after returning the book" do
        # First reservation
        first_reservation = create(:reservation, book: book, user: user, returned_at: nil)
        expect(first_reservation).to be_valid

        # Return the book
        first_reservation.update(returned_at: Time.current)

        # New reservation should be allowed
        second_reservation = build(:reservation, book: book, user: user)
        expect(second_reservation).to be_valid
      end
    end

    describe "has_available_copies validation" do
      let(:user) { create(:user) }

      context "when book has available copies" do
        let(:book) { create(:book, total_copies: 5) }

        it "allows creating a reservation" do
          reservation = build(:reservation, book: book, user: user)

          expect(reservation).to be_valid
        end
      end

      context "when book has copies but all are reserved" do
        let(:book) { create(:book, total_copies: 2) }
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }

        before do
          create(:reservation, book: book, user: user1, returned_at: nil)
          create(:reservation, book: book, user: user2, returned_at: nil)
        end

        it "prevents creating another reservation" do
          reservation = build(:reservation, book: book, user: user)

          expect(reservation).not_to be_valid
          expect(reservation.errors[:book]).to include("has no available copies")
        end
      end
    end
  end

  describe "callbacks" do
    describe "before_create hook" do
      let(:book) { create(:book) }
      let(:user) { create(:user) }

      it "sets due_on to borrowed_on + DUE_WITHIN when creating a reservation" do
        borrowed_date = Date.new(2025, 1, 15)
        reservation = build(:reservation, book:, user:, borrowed_on: borrowed_date)

        expect(reservation.due_on).to be_nil # Should be nil before saving

        reservation.save!

        expected_due_date = borrowed_date + Reservation::DUE_WITHIN
        expect(reservation.due_on).to eq(expected_due_date)
      end

      context "when due_on is manually set" do
        it "overrides the manual value with the calculated value" do
          manual_due_date = Date.today + 30.days
          reservation = Reservation.new(
            book: book,
            user: user,
            borrowed_on: Date.today,
            due_on: manual_due_date
          )

          reservation.save!

          # The hook should override the manual value
          expected_due_date = Date.today + Reservation::DUE_WITHIN
          expect(reservation.due_on).to eq(expected_due_date)
          expect(reservation.due_on).not_to eq(manual_due_date)
        end
      end
    end
  end

  describe "scopes" do
    let(:book) { create(:book) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }

    let!(:active_reservation) { create(:reservation, book: book, user: user1, returned_at: nil) }
    let!(:returned_reservation) { create(:reservation, :returned, book: book, user: user2) }
    let!(:overdue_reservation) { create(:reservation, :overdue, book: book, user: create(:user), returned_at: nil) }

    # It is necessary because there is a before_create callback that sets due_on
    before { overdue_reservation.update_column(:due_on, 2.day.ago) }

    describe ".not_returned" do
      it "returns reservations that haven't been returned" do
        not_returned = Reservation.not_returned

        expect(not_returned.count).to eq(2)
        expect(not_returned).to include(active_reservation, overdue_reservation)
        expect(not_returned).not_to include(returned_reservation)
      end
    end

    describe ".returned" do
      it "returns reservations that have been returned" do
        returned = Reservation.returned

        expect(returned.count).to eq(1)
        expect(returned).to include(returned_reservation)
        expect(returned).not_to include(active_reservation, overdue_reservation)
      end
    end

    describe ".overdue" do
      it "returns not returned reservations that are past due date" do
        overdue = Reservation.overdue

        expect(overdue.count).to eq(1)
        expect(overdue).to include(overdue_reservation)
        expect(overdue).not_to include(active_reservation, returned_reservation)
      end

      it "returns overdue reservations correctly" do
        # Create reservation due yesterday
        overdue_reservation = create(:reservation,
          book: book,
          user: user3,
          returned_at: nil
        )
        overdue_reservation.update_column(:due_on, 2.days.ago) # Set due_on to 2 days ago to make it overdue

        # Create reservation due tomorrow
        future_reservation = create(:reservation,
          book: create(:book),
          user: user2,
          due_on: Date.today + 1.day,
          returned_at: nil
        )

        overdue_reservations = Reservation.overdue
        expect(overdue_reservations).to include(overdue_reservation)
        expect(overdue_reservations).not_to include(future_reservation)
      end
    end

    describe ".due_today" do
      it "returns not returned reservations that are due today" do
        due_today_reservation = create(:reservation,
          book: create(:book),
          user: user3,
          returned_at: nil
        )
        due_today_reservation.update_column(:due_on, Date.current)

        due_tomorrow_reservation = create(:reservation,
          book: create(:book),
          user: user2,
          returned_at: nil
        )
        due_tomorrow_reservation.update_column(:due_on, Date.tomorrow)

        returned_due_today = create(:reservation,
          book: create(:book),
          user: user1,
          returned_at: Time.current
        )
        returned_due_today.update_column(:due_on, Date.current)

        due_today_reservations = Reservation.due_today

        expect(due_today_reservations).to include(due_today_reservation)
        expect(due_today_reservations).not_to include(due_tomorrow_reservation, returned_due_today, overdue_reservation)
      end

      it "excludes returned reservations even if they were due today" do
        returned_today = create(:reservation,
          book: create(:book),
          user: user1,
          returned_at: Time.current
        )
        returned_today.update_columns(due_on: Date.current)

        due_today_reservations = Reservation.due_today

        expect(due_today_reservations).not_to include(returned_today)
      end

      it "excludes overdue reservations" do
        due_today_reservations = Reservation.due_today

        expect(due_today_reservations).not_to include(overdue_reservation)
      end
    end
  end

  describe "#return" do
    let(:book) { create(:book) }
    let(:user) { create(:user) }

    context "when update is successful" do
      it "updates returned_at timestamp and returns true" do
        reservation = create(:reservation, book:, user:, borrowed_on: Date.today)

        expect(reservation.returned_at).to be_nil

        result = reservation.return

        expect(result).to be true
        expect(reservation.returned_at).to be_within(1.second).of(Time.current)
      end
    end

    context "when update fails" do
      it "does not change returned_at and returns false" do
        reservation = create(:reservation, book:, user:, borrowed_on: Date.today)

        # Stub the update method to return false (simulating a failed update)
        allow(reservation).to receive(:update).and_return(false)

        expect(reservation.returned_at).to be_nil

        result = reservation.return

        expect(result).to be false
        expect(reservation.returned_at).to be_nil
      end
    end
  end

  describe "constants" do
    it "DUE_WITHIN value" do
      expect(Reservation::DUE_WITHIN).to eq(2.weeks)
    end
  end
end
