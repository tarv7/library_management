class Api::V1::BaseController < ApplicationController
  attr_reader :current_user

  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def authenticate_user!
    header = request.headers["Authorization"]
    token = header.split(" ").last if header.present?
    decoded = JsonWebToken.decode(token)

    return not_authorized if decoded.nil?

    @current_user = User.find(decoded[:user_id])
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    not_authorized
  end

  def not_authorized
    render json: { error: "Not Authorized" }, status: :unauthorized
  end

  def not_found
    render json: { error: "Record not found" }, status: :not_found
  end
end
