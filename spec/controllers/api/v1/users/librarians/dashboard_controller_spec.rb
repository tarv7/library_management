require 'rails_helper'

RSpec.describe "Api::V1::Users::Librarians::Dashboard", type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:book1) { create(:book) }
  let(:book2) { create(:book) }
  let(:book3) { create(:book) }

  let!(:due_today_reservation) do
    create(:reservation, user: member, book: book1, borrowed_on: 2.weeks.ago, due_on: Date.current)
  end

  let!(:overdue_reservation) do
    create(:reservation, user: member, book: book2, borrowed_on: 3.weeks.ago, due_on: 1.week.ago)
  end

  let!(:not_overdue_reservation) do
    create(:reservation, user: member, book: book3)
  end

  let(:librarian_token) { JsonWebToken.encode_user(librarian) }
  let(:headers) { { "Authorization" => "Bearer #{librarian_token}" } }

  describe "GET /api/v1/users/librarians/dashboard" do
    it "returns success status" do
      get "/api/v1/users/librarians/dashboard.json", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "returns library statistics" do
      get "/api/v1/users/librarians/dashboard.json", headers: headers

      expect(json_response["statistics"]).to be_present
      expect(json_response["statistics"]["total_books"]).to eq(3)
      expect(json_response["statistics"]["total_borrowed_books"]).to eq(3)
      expect(json_response["statistics"]["books_due_today_count"]).to eq(1)
      expect(json_response["statistics"]["members_with_overdue_books_count"]).to eq(1)
    end

    it "returns books due today with member and book details" do
      get "/api/v1/users/librarians/dashboard.json", headers: headers

      expect(json_response["books_due_today"]).to be_present
      expect(json_response["books_due_today"].count).to eq(1)

      due_today_book = json_response["books_due_today"].first
      expect(due_today_book["reservation_id"]).to eq(due_today_reservation.id)
      expect(due_today_book["due_on"]).to eq(Date.current.to_s)
      expect(due_today_book["member"]["id"]).to eq(member.id)
      expect(due_today_book["member"]["name"]).to eq(member.name)
      expect(due_today_book["book"]["title"]).to eq(book1.title)
    end

    it "returns members with overdue books" do
      get "/api/v1/users/librarians/dashboard.json", headers: headers

      expect(json_response["members_with_overdue_books"]).to be_present
      expect(json_response["members_with_overdue_books"].count).to eq(1)

      overdue_member = json_response["members_with_overdue_books"].first
      expect(overdue_member["member_id"]).to eq(member.id)
      expect(overdue_member["member_name"]).to eq(member.name)
      expect(overdue_member["overdue_books"]).to be_present
      expect(overdue_member["overdue_books"].count).to eq(1)

      overdue_book = overdue_member["overdue_books"].first
      expect(overdue_book["reservation_id"]).to eq(overdue_reservation.id)
      expect(overdue_book["days_overdue"]).to be > 0
      expect(overdue_book["book"]["title"]).to eq(book2.title)
    end

    it "returns librarian information" do
      get "/api/v1/users/librarians/dashboard.json", headers: headers

      expect(json_response["librarian"]).to be_present
      expect(json_response["librarian"]["id"]).to eq(librarian.id)
      expect(json_response["librarian"]["name"]).to eq(librarian.name)
    end

    context "when user is a member" do
      let(:member_token) { JsonWebToken.encode_user(member) }
      let(:member_headers) { { "Authorization" => "Bearer #{member_token}" } }

      it "returns unauthorized status" do
        get "/api/v1/users/librarians/dashboard.json", headers: member_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Not Authorized")
      end
    end

    context "when user is not authenticated" do
      before do
        allow(JsonWebToken).to receive(:decode).and_return(nil)
      end

      it "returns unauthorized status" do
        get "/api/v1/users/librarians/dashboard.json", headers: { "Authorization" => "Bearer invalid_token" }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Not Authorized")
      end
    end
  end
end
