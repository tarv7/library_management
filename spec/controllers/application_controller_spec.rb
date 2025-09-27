require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render json: { message: "Success", user: current_user&.id }
    end
  end

  let!(:user) do
    User.create!(
      name: "Test User",
      email_address: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "member"
    )
  end

  let(:valid_token) { JsonWebToken.encode(user_id: user.id) }

  describe "#authenticate_user!" do
    context "when valid token is provided" do
      before do
        request.headers["Authorization"] = "Bearer #{valid_token}"
      end

      it "authenticates the user successfully" do
        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["user"]).to eq(user.id)
      end

      it "sets current_user" do
        get :index

        expect(controller.current_user).to eq(user)
      end
    end

    context "when no token is provided" do
      it "returns unauthorized status" do
        get :index

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Not Authorized")
      end
    end

    context "when invalid token is provided" do
      before do
        request.headers["Authorization"] = "Bearer invalid_token"
      end

      it "returns unauthorized status" do
        get :index

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Not Authorized")
      end
    end

    context "when token is expired" do
      let(:expired_token) { JsonWebToken.encode({ user_id: user.id }, 1.hour.ago) }

      before do
        request.headers["Authorization"] = "Bearer #{expired_token}"
      end

      it "returns unauthorized status" do
        get :index

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Not Authorized")
      end
    end

    context "when user does not exist" do
      let(:token_with_invalid_user) { JsonWebToken.encode(user_id: 999999) }

      before do
        request.headers["Authorization"] = "Bearer #{token_with_invalid_user}"
      end

      it "returns unauthorized status" do
        get :index

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Not Authorized")
      end
    end
  end
end
