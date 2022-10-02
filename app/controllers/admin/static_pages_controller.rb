class Admin::StaticPagesController < Admin::BaseController
  def index
    @user_sum = User.count
    @user_sum_this_month = User.this_month.count
    @subject_sum = Subject.count
    @subject_sum_this_month = Subject.this_month.count
    @exam_sum = Exam.count
    @exam_sum_this_month = Exam.this_month.count
    @exam_passed_sum = Exam.passed.count
    @exam_passed_sum_this_month = Exam.passed.this_month.count
    @pagy, @subject_item = pagy Subject.all, items: Settings.pagy
  end
end
