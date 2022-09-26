class SubjectsController < ApplicationController
  def index
    return unless user_signed_in?

    @search = Subject.ransack name_cont: params[:q] ? params[:q][:name] : ""
    @search.sorts = params.dig(:q, :s) || "id asc"
    @pagy, @subject_item = pagy @search.result, items: Settings.pagy
  end
end
