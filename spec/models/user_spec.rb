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
end
