class Admin::UsersController < Admin::BaseController
  def index
    @search = User.ransack email_cont: params[:q] ? params[:q][:email] : ""
    @pagy, @user_item = pagy @search.result.user, items: Settings.pagy
  end

  def destroy
    @user = User.find_by id: params[:id]
    if @user.destroy
      flash[:success] = t ".user_deleted"
    else
      flash[:danger] = t ".user_fail"
    end
    redirect_to admin_users_path
  end
end
