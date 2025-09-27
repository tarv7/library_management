require "rails_helper"

RSpec.describe Api::V1::AuthController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/api/v1/auth").to route_to("api/v1/auth#create")
    end
  end
end
