module ApplicationHelper
  include Pagy::Frontend
  # rubocop:disable Rails/OutputSafety
  def toastr_flash
    flash.each_with_object([]) do |(type, message), flash_messages|
      type = "success" if type == "notice"
      type = "error" if type == "alert"
      type = "warning" if type == "danger"
      text = "<script>toastr.#{type}('#{message}');</script>"
      flash_messages << text.html_safe if message
    end.join("\n").html_safe
  end

  # rubocop:enable Rails/OutputSafety
  def full_title page_title = ""
    base_title = t "base_title"
    page_title.blank? ? base_title : [page_title, base_title].join(" | ")
  end

  def error_message object, field
    message = object.errors[field].first if object.errors[field].present?
    content_tag(:div, message, class: "text-danger")
  end

  def icon_active_or_inactive user
    if user.activated
      "fa-lock fa icon inactive-icon"
    else
      "fa fa-unlock icon active-icon"
    end
  end

  def status_exam exam
    content_tag(:span, exam.status_i18n(exam.status),
                class: "status #{exam.status}-status")
  end

  def button_exam exam
    case exam.status
    when "ready"
      link_to t("ready"),
              subject_exam_path(exam.subject.id, exam.id),
              class: "btn btn-primary"
    when "doing"
      link_to t("continue"),
              subject_exam_path(exam.subject.id, exam.id),
              class: "btn btn-info"
    else
      link_to t("view"),
              subject_exam_path(exam.subject.id, exam.id),
              class: "btn btn-info"
    end
  end

  def status_subject subject
    list_exam = Exam.by_subject_id(subject.id).by_user(current_user.id)
    return "" if list_exam.empty?
    return "active" unless list_exam.by_statuses("passed").empty?

    "inactive"
  end

  def status_account user
    user.activated ? "active" : "inactive"
  end

  def count_passed_exam subject
    subject.exams.passed.size
  end

  def count_attended_subject list_exam
    list_exam.select("distinct(subject_id)").size
  end

  def user_link user
    if user.activated?
      link_to user.name, admin_user_exams_path(user.id)
    else
      user.name
    end
  end

  def redirect_back_or default
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
