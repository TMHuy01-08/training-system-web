class Admin::SubjectsController < Admin::BaseController
  before_action :find_subject, except: %i(index new create)

  def index
    @search = Subject.ransack name_cont: params[:q] ? params[:q][:name] : ""
    @search.sorts = params.dig(:q, :s) || "id asc"
    @pagy, @subject_item = pagy @search.result, items: Settings.pagy
  end

  def new
    @subject = Subject.new
    return if @subject

    flash.now[:error] = t ".not_found"
    redirect_to root_path
  end

  def create
    @subject = Subject.new subject_params
    if @subject.save
      flash[:success] = t ".success_create"
      redirect_to admin_subjects_path
    else
      flash.now[:error] = t ".fail_create"
      render :new
    end
  end

  def edit; end

  def update
    if @subject.update subject_params
      flash[:success] = t ".update_success"
      redirect_to admin_subjects_path
    else
      flash[:danger] = t ".update_false"
      render :edit
    end
  end

  def destroy
    if @subject.destroy
      flash[:success] = t ".subject_deleted"
    else
      flash[:danger] = t ".subject_delete_fail"
    end
    redirect_to admin_subjects_path
  end

  private
  def subject_params
    params.require(:subject).permit Subject::SUBJECT_ATTRS
  end

  def find_subject
    @subject = Subject.find_by id: params[:id]
    return if @subject.present?

    flash[:danger] = t ".not_found"
    redirect_to admin_subjects_path
  end
end
