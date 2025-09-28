require 'rails_helper'

RSpec.describe "Api::V1::Users::Members::Dashboard", type: :request do
  let(:member) { create(:user, :member) }
  let(:book) { create(:book) }
  let!(:borrowed_reservation) { create(:reservation, user: member, book: book) }
  let!(:overdue_reservation) do
    create(:reservation, user: member, book: create(:book),
           borrowed_on: 3.weeks.ago, due_on: 1.week.ago)
  end

  let(:member_token) { JsonWebToken.encode(user_id: member.id) }
  let(:headers) { { "Authorization" => "Bearer #{member_token}" } }

  describe "GET /api/v1/users/members/dashboard" do
    it "returns success status" do
      get "/api/v1/users/members/dashboard.json", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "returns borrowed books with due dates" do
      get "/api/v1/users/members/dashboard.json", headers: headers

      expect(json_response["borrowed_books"]).to be_present
      expect(json_response["borrowed_books"].count).to eq(2)

      borrowed_book = json_response["borrowed_books"].first
      expect(borrowed_book).to have_key("reservation_id")
      expect(borrowed_book).to have_key("borrowed_on")
      expect(borrowed_book).to have_key("due_on")
      expect(borrowed_book["book"]).to have_key("title")
      expect(borrowed_book["book"]).to have_key("author")
    end

    it "returns overdue books with days overdue" do
      get "/api/v1/users/members/dashboard.json", headers: headers

      expect(json_response["overdue_books"]).to be_present
      expect(json_response["overdue_books"].count).to eq(1)

      overdue_book = json_response["overdue_books"].first
      expect(overdue_book).to have_key("due_on")
      expect(overdue_book).to have_key("days_overdue")
      expect(overdue_book["days_overdue"]).to be > 0
    end

    it "returns member information and summary" do
      get "/api/v1/users/members/dashboard.json", headers: headers

      expect(json_response["member"]).to be_present
      expect(json_response["member"]["id"]).to eq(member.id)
      expect(json_response["member"]["name"]).to eq(member.name)

      expect(json_response["summary"]).to be_present
      expect(json_response["summary"]["total_borrowed_books"]).to eq(2)
      expect(json_response["summary"]["total_overdue_books"]).to eq(1)
    end

    context "when user is a librarian" do
      let(:librarian) { create(:user, :librarian) }
      let(:librarian_token) { JsonWebToken.encode(user_id: librarian.id) }
      let(:librarian_headers) { { "Authorization" => "Bearer #{librarian_token}" } }

      it "returns unauthorized status" do
        get "/api/v1/users/members/dashboard.json", headers: librarian_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Not Authorized")
      end
    end

    context "when user is not authenticated" do
      before do
        allow(JsonWebToken).to receive(:decode).and_return(nil)
      end

      it "returns unauthorized status" do
        get "/api/v1/users/members/dashboard.json", headers: { "Authorization" => "Bearer invalid_token" }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Not Authorized")
      end
    end
  end
end
