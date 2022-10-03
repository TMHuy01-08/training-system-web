class Api::UsersController < Api::ApiController
  def create
    @user = User.new user_params
    if @user.save
      render json: {notice: "Success"}
    else
      email = get_errors @user, :email
      name = get_errors @user, :name
      pass = get_errors @user, :password

      render json: {
        email: email,
        name: name,
        password: pass
      }
    end
  end

  def edit
    user = User.find_by id: params[:id]
    if user.present?
      render json: {
        name: user.name,
        email: user.email
      }
    else
      render json: {notice: "Error"}
    end
  end

  def update
    user = User.find_by id: params[:id]
    if user&.valid_password?(params[:cr_password])
      if user.update profile_params
        render json: {notice: "Success"}
      else
        render json: {notice: "Failed"}
      end
    else
      render json: {notice: "Can't not find user / Password is incorrect"}
    end
  end

  private
  def get_errors object, field
    object.errors[field].present? ? object.errors[field].first : ""
  end

  def profile_params
    params.permit(:name, :email, :password)
  end
end
