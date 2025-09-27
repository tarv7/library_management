class AuthController < ApplicationController
  before_action :set_user, only: :create

  def create
    if @user&.authenticate(user_params[:password])
      token = JsonWebToken.encode(user_id: @user.id)

      render json: { token: token }, status: :created
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password)
  end

  def set_user
    @user = User.find_by(email_address: user_params[:email_address])
  end
end
