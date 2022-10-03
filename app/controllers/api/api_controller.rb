class Api::ApiController < ActionController::API
  private
  def user_params
    params.permit(:name, :email, :password)
  end
end
