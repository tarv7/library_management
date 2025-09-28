require "rails_helper"

RSpec.describe "Librarians Dashboard routing", type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/api/v1/users/librarians/dashboard").to route_to("api/v1/users/librarians/dashboard#show")
    end
  end
end
