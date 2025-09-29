require 'rails_helper'

RSpec.describe "Api::V1::Reservations", type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:book1) { create(:book, title: "Test Book 1") }
  let(:book2) { create(:book, title: "Test Book 2") }

  let!(:active_reservation) { create(:reservation, book: book1, user: member, borrowed_on: 5.days.ago.to_date, returned_at: nil) }
  let!(:returned_reservation) { create(:reservation, book: book2, user: member, borrowed_on: 20.days.ago.to_date, returned_at: 5.days.ago) }
  let!(:overdue_reservation) { create(:reservation, book: book1, user: librarian, borrowed_on: 30.days.ago.to_date, returned_at: nil) }

  describe "GET /api/v1/reservations" do
    context "when user is a librarian" do
      let(:headers) { auth_headers(librarian) }

      it "returns all reservations" do
        get "/api/v1/reservations", headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('reservations')
        expect(json_response).to have_key('metadata')

        reservations = json_response['reservations']
        expect(reservations.count).to be >= 3

        # Check structure of first reservation
        first_reservation = reservations.first
        expect(first_reservation).to have_key('id')
        expect(first_reservation).to have_key('book_id')
        expect(first_reservation).to have_key('user_id')
        expect(first_reservation).to have_key('borrowed_on')
        expect(first_reservation).to have_key('due_on')
        expect(first_reservation).to have_key('returned_at')
        expect(first_reservation).to have_key('book')
        expect(first_reservation).to have_key('user')
        expect(first_reservation).to have_key('status')
      end

      it "filters reservations by book_id" do
        get "/api/v1/reservations", params: { book_id: book1.id }, headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        reservations = json_response['reservations']

        expect(reservations.count).to eq(2) # active_reservation and overdue_reservation
        reservations.each do |reservation|
          expect(reservation['book_id']).to eq(book1.id)
        end
      end

      it "filters reservations by user_id" do
        get "/api/v1/reservations", params: { user_id: member.id }, headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        reservations = json_response['reservations']

        expect(reservations.count).to eq(2) # active_reservation and returned_reservation
        reservations.each do |reservation|
          expect(reservation['user_id']).to eq(member.id)
        end
      end

      it "filters reservations by situation - not_returned" do
        get "/api/v1/reservations", params: { situation: "not_returned" }, headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        reservations = json_response['reservations']

        reservations.each do |reservation|
          expect(reservation['returned_at']).to be_nil
        end
      end

      it "filters reservations by situation - returned" do
        get "/api/v1/reservations", params: { situation: "returned" }, headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        reservations = json_response['reservations']

        reservations.each do |reservation|
          expect(reservation['returned_at']).not_to be_nil
        end
      end

      it "filters reservations by situation - overdue" do
        get "/api/v1/reservations", params: { situation: "overdue" }, headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        reservations = json_response['reservations']

        expect(reservations.count).to be >= 1
        reservations.each do |reservation|
          expect(reservation['returned_at']).to be_nil
          expect(Date.parse(reservation['due_on'])).to be < Date.current
        end
      end

      it "combines multiple filters" do
        get "/api/v1/reservations", params: { book_id: book1.id, situation: "not_returned" }, headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        reservations = json_response['reservations']

        reservations.each do |reservation|
          expect(reservation['book_id']).to eq(book1.id)
          expect(reservation['returned_at']).to be_nil
        end
      end

      it "includes metadata with filters and statistics" do
        get "/api/v1/reservations", params: { book_id: book1.id }, headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        metadata = json_response['metadata']

        expect(metadata).to have_key('total_count')
        expect(metadata).to have_key('filters')
        expect(metadata).to have_key('statistics')

        expect(metadata['filters']['book_id']).to eq(book1.id.to_s)

        statistics = metadata['statistics']
        expect(statistics).to have_key('active_count')
        expect(statistics).to have_key('returned_count')
        expect(statistics).to have_key('overdue_count')
        expect(statistics).to have_key('due_today_count')
      end

      it "returns empty results for non-existent book" do
        get "/api/v1/reservations", params: { book_id: -1 }, headers: headers

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['reservations']).to be_empty
        expect(json_response['metadata']['total_count']).to eq(0)
      end
    end

    context "when user is a member" do
      let(:headers) { auth_headers(member) }

      it "returns unauthorized" do
        get "/api/v1/reservations", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/api/v1/reservations"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
