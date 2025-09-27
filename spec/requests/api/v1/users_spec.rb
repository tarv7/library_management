require 'rails_helper'

RSpec.describe "/api/v1/users", type: :request do
  let(:valid_attributes) {
    {
      user: {
        email_address: "test@example.com",
        password: "password",
        password_confirmation: "password",
        name: "Test User",
        role: "librarian"
      }
    }
  }

  let(:invalid_attributes) {
    {
      user: {
        email_address: "",
        password: "",
        password_confirmation: "",
        name: "",
        role: ""
      }
    }
  }

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post api_v1_users_url, params: valid_attributes, as: :json
        }.to change(User, :count).by(1)
      end

      it "renders a JSON response with the new user" do
        post api_v1_users_url, params: valid_attributes, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(json_response).to eql({ "id" => User.last.id, "email_address" => "test@example.com", "name" => "Test User", "role" => "librarian" })
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post api_v1_users_url, params: invalid_attributes, as: :json
        }.to change(User, :count).by(0)
      end

      it "renders a JSON response with errors for the new user" do
        post api_v1_users_url, params: invalid_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(json_response).to eql({ "email_address" => [ "can't be blank", "is invalid" ], "password" => [ "can't be blank" ], "name" => [ "can't be blank" ], "role" => [ "can't be blank" ] })
      end
    end
  end
end
