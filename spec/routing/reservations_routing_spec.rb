require "rails_helper"

RSpec.describe Api::V1::Books::ReservationsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/api/v1/books/1/reservations").to route_to(
        controller: "api/v1/books/reservations",
        action: "create",
        book_id: "1"
      )
    end

    it "routes to #update via PUT" do
      expect(put: "/api/v1/books/1/reservations/1").to route_to(
        controller: "api/v1/books/reservations",
        action: "update",
        book_id: "1",
        id: "1"
      )
    end

    it "routes to #update via PATCH" do
      expect(patch: "/api/v1/books/1/reservations/1").to route_to(
        controller: "api/v1/books/reservations",
        action: "update",
        book_id: "1",
        id: "1"
      )
    end
  end
end
