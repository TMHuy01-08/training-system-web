class Api::SessionsController < Api::ApiController
  def create
    user = User.find_by email: params[:email]
    if user&.valid_password?(params[:password])
      handle_login user
    else
      render json: {notice: "Invalid email/password combination"}
    end
  end

  private
  def handle_login current_user
    case current_user.role_id
    when "admin"
      render json:
                  {notice: "Mobile app doesn't support with admin account"}
    when "user"
      if current_user.activated
        render json: {user_id: current_user.id}
      else
        render json:
                  {notice: "Contact the administrator to activate the account"}
      end
    end
  end
end
