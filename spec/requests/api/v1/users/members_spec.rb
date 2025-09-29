require 'rails_helper'

RSpec.describe "Api::V1::Users::Members", type: :request do
  let!(:librarian) { create(:user, :librarian) }
  let!(:librarian2) { create(:user, :librarian, name: "David Admin") }
  let!(:member1) { create(:user, :member, name: "Alice Johnson") }
  let!(:member2) { create(:user, :member, name: "Bob Smith") }
  let!(:member3) { create(:user, :member, name: "Carol Wilson") }

  describe "GET /api/v1/users/members" do
    context "when user is a librarian" do
      let(:headers) { auth_headers(librarian) }

      it "returns all (and only) members" do
        get "/api/v1/users/members", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(3)

        names = json_response.map { |user| user['name'] }
        expect(names).to eq([ 'Alice Johnson', 'Bob Smith', 'Carol Wilson' ])
      end

      it "returns correct member attributes" do
        get "/api/v1/users/members", headers: headers

        expect(response).to have_http_status(:ok)

        member = json_response.first
        expect(member).to have_key('id')
        expect(member).to have_key('name')
        expect(member).to have_key('email_address')
        expect(member).to have_key('role')
        expect(member).to have_key('created_at')
        expect(member).to have_key('updated_at')
        expect(member['role']).to eq('member')
      end

      it "returns empty array when no members exist" do
        User.where(role: :member).destroy_all

        get "/api/v1/users/members", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response).to be_empty
      end
    end

    context "when user is a member" do
      let(:member) { create(:user, :member) }
      let(:headers) { auth_headers(member) }

      it "returns unauthorized" do
        get "/api/v1/users/members", headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response).to have_key('error')
        expect(json_response['error']).to eq('Not Authorized')
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/api/v1/users/members"

        expect(response).to have_http_status(:unauthorized)
        expect(json_response).to have_key('error')
        expect(json_response['error']).to eq('Not Authorized')
      end
    end
  end
end
