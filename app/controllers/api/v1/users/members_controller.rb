class Api::V1::Users::MembersController < Api::V1::BaseController
  before_action :authorized_librarian!, only: %i[ index ]

  def index
    @members = User.member.order(:name)

    render json: @members, status: :ok
  end
end
