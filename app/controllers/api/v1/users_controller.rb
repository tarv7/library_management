class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  def create
    @user = User.new(user_params)

    if @user.save
      render :show, status: :created
    else
      render json: @user.errors, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :name, :role)
  end
end
