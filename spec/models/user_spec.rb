require 'rails_helper'

RSpec.describe User, type: :model do
  subject {
    described_class.new(
      email_address: "thales@gmail.com",
      password: "123456",
      password_confirmation: "123456",
      name: "Thales",
      role: "librarian"
    )
  }

  describe "Validations" do
    describe "name" do
      it "is valid with a name" do
        subject.name = "Thales"
        expect(subject).to be_valid
      end

      it "is invalid without a name" do
        subject.name = nil
        expect(subject).to be_invalid
        expect(subject.errors[:name]).to include("can't be blank")
      end
    end

    describe "email_address" do
      it "is valid with a valid email address" do
        subject.email_address = "thales@gmail.com"
        expect(subject).to be_valid
      end

      it "is invalid without an email address" do
        subject.email_address = nil
        expect(subject).to be_invalid
        expect(subject.errors[:email_address]).to include("can't be blank")
      end

      it "is invalid with a duplicate email address" do
        described_class.create!(email_address: "thales@gmail.com", password: "123456", password_confirmation: "123456", name: "Thales", role: "librarian")
        expect(subject).to be_invalid
        expect(subject.errors[:email_address]).to include("has already been taken")
      end

      it "is invalid with an improperly formatted email address" do
        subject.email_address = "invalid_email"
        expect(subject).to be_invalid
        expect(subject.errors[:email_address]).to include("is invalid")
      end
    end

    describe "role" do
      it "is valid with a valid role" do
        subject.role = "librarian"
        expect(subject).to be_valid
      end

      it "is invalid without a role" do
        subject.role = nil
        expect(subject).to be_invalid
        expect(subject.errors[:role]).to include("can't be blank")
      end

      it "is invalid with an invalid role" do
        expect do
          subject.role = "invalid_role"
        end.to raise_error(ArgumentError, "'invalid_role' is not a valid role")
      end
    end
  end

  describe "scopes" do
    let!(:member1) { create(:user, :member) }
    let!(:member2) { create(:user, :member) }
    let!(:librarian1) { create(:user, :librarian) }
    let!(:librarian2) { create(:user, :librarian) }

    describe ".member" do
      it "returns only users with member role" do
        members = User.member

        expect(members).to include(member1, member2)
        expect(members).not_to include(librarian1, librarian2)
        expect(members.count).to eq(2)
      end
    end

    describe ".librarian" do
      it "returns only users with librarian role" do
        librarians = User.librarian

        expect(librarians).to include(librarian1, librarian2)
        expect(librarians).not_to include(member1, member2)
        expect(librarians.count).to eq(2)
      end
    end

    describe ".with_overdue_books" do
      let(:book1) { create(:book) }
      let(:book2) { create(:book) }

      it "returns only members with overdue reservations" do
        # Member with overdue reservation
        overdue_reservation = create(:reservation, user: member1, book: book1, returned_at: nil)
        overdue_reservation.update_column(:due_on, 1.day.ago)

        # Member without overdue reservations
        create(:reservation, user: member2, book: book2, returned_at: nil)

        members_with_overdue = User.with_overdue_books

        expect(members_with_overdue.count).to eq(1)
        expect(members_with_overdue).to include(member1)
        expect(members_with_overdue).not_to include(member2, librarian1, librarian2)
      end
    end
  end
end
