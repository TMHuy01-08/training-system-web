class Api::SubjectsController < Api::ApiController
  def index
    @search = Subject.ransack name_cont: params[:q] ? params[:q][:name] : ""

    @list_subject = @search.result
    render json: @list_subject
  end
end
