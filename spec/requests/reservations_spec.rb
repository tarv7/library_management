require "rails_helper"

RSpec.describe "/api/v1/books/:book_id/reservations", type: :request do
  let!(:member_user) { create(:user, :member) }
  let!(:librarian_user) { create(:user, :librarian) }
  let!(:other_user) { create(:user, :member) }
  let!(:book) { create(:book, total_copies: 2) }
  let!(:book_no_copies) { create(:book, total_copies: 0) }

  let(:member_auth_token) { JsonWebToken.encode_user(member_user) }
  let(:librarian_auth_token) { JsonWebToken.encode_user(librarian_user) }
  let(:member_headers) { { "Authorization" => "Bearer #{member_auth_token}" } }
  let(:librarian_headers) { { "Authorization" => "Bearer #{librarian_auth_token}" } }

  describe "POST /api/v1/books/:book_id/reservations" do
    context "when user is authenticated" do
      context "with valid parameters" do
        it "creates a new Reservation" do
          expect {
            post "/api/v1/books/#{book.id}/reservations",
                 headers: member_headers, as: :json
          }.to change(Reservation, :count).by(1)
        end

        it "renders a JSON response with the new reservation" do
          post "/api/v1/books/#{book.id}/reservations",
               headers: member_headers, as: :json

          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(json_response["book_id"]).to eq(book.id)
          expect(json_response["user_id"]).to eq(member_user.id)
          expect(json_response["borrowed_on"]).to eq(Date.today.to_s)
        end

        it "sets borrowed_on to today's date" do
          post "/api/v1/books/#{book.id}/reservations",
               headers: member_headers, as: :json

          reservation = Reservation.find(json_response["id"])
          expect(reservation.borrowed_on).to eq(Date.today)
        end
      end

      context "when book has no available copies" do
        it "does not create a new Reservation" do
          expect {
            post "/api/v1/books/#{book_no_copies.id}/reservations",
                 headers: member_headers, as: :json
          }.not_to change(Reservation, :count)
        end

        it "renders a JSON response with errors" do
          post "/api/v1/books/#{book_no_copies.id}/reservations",
               headers: member_headers, as: :json

          expect(response).to have_http_status(:unprocessable_content)
          expect(json_response["book"]).to include("has no available copies")
        end
      end

      context "when user already has the book borrowed" do
        let!(:existing_reservation) { create(:reservation, book: book, user: member_user) }

        it "does not create a new Reservation" do
          expect {
            post "/api/v1/books/#{book.id}/reservations",
                 headers: member_headers, as: :json
          }.not_to change(Reservation, :count)
        end

        it "renders a JSON response with errors" do
          post "/api/v1/books/#{book.id}/reservations",
               headers: member_headers, as: :json

          expect(response).to have_http_status(:unprocessable_content)
          expect(json_response["book"]).to include("is already borrowed")
        end
      end

      context "when book does not exist" do
        it "returns 404 not found" do
          post "/api/v1/books/99999/reservations",
               headers: member_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when user is librarian" do
      it "returns 401 unauthorized (librarians cannot create reservations)" do
        post "/api/v1/books/#{book.id}/reservations",
             headers: librarian_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is not authenticated" do
      it "returns 401 unauthorized" do
        post "/api/v1/books/#{book.id}/reservations", as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid auth token" do
      let(:invalid_headers) { { "Authorization" => "Bearer invalid_token" } }

      it "returns 401 unauthorized" do
        post "/api/v1/books/#{book.id}/reservations",
             headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/v1/books/:book_id/reservations/:id" do
    let!(:reservation) { create(:reservation, book: book, user: member_user) }

    context "when user is librarian" do
      context "when returning the book" do
        it "updates the reservation with returned_at timestamp" do
          patch "/api/v1/books/#{book.id}/reservations/#{reservation.id}",
                headers: librarian_headers, as: :json

          reservation.reload
          expect(reservation.returned_at).not_to be_nil
          expect(reservation.returned_at).to be_within(1.second).of(Time.current)
        end

        it "renders a JSON response with the updated reservation" do
          patch "/api/v1/books/#{book.id}/reservations/#{reservation.id}",
                headers: librarian_headers, as: :json

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(json_response["returned_at"]).not_to be_nil
        end
      end

      context "when reservation is already returned" do
        let!(:returned_reservation) { create(:reservation, :returned, book: book, user: other_user) }

        it "still updates successfully" do
          old_returned_at = returned_reservation.returned_at

          patch "/api/v1/books/#{book.id}/reservations/#{returned_reservation.id}",
                headers: librarian_headers, as: :json

          returned_reservation.reload
          expect(returned_reservation.returned_at).not_to eq(old_returned_at)
          expect(response).to have_http_status(:ok)
        end
      end

      context "when reservation does not exist" do
        it "returns 404 not found" do
          patch "/api/v1/books/#{book.id}/reservations/99999",
                headers: librarian_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when user is member" do
      it "returns 401 unauthorized (members cannot update reservations)" do
        patch "/api/v1/books/#{book.id}/reservations/#{reservation.id}",
              headers: member_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is not authenticated" do
      it "returns 401 unauthorized" do
        patch "/api/v1/books/#{book.id}/reservations/#{reservation.id}", as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid auth token" do
      let(:invalid_headers) { { "Authorization" => "Bearer invalid_token" } }

      it "returns 401 unauthorized" do
        patch "/api/v1/books/#{book.id}/reservations/#{reservation.id}",
              headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
