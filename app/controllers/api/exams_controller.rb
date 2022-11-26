class Api::ExamsController < Api::ApiController
  include ExamsHelper
  before_action :find_exam, only: %i(show update)
  before_action :add_answer_to_record, only: %i(update)
  before_action :time_out, only: %i(index)

  def index
    @list_exam = Exam.newest.by_subject_id(params[:subject_id])
                     .by_user(params[:user_id])
    render json: @list_exam
  end

  def create
    user = User.find_by id: params[:user_id]
    @exam = user.exams.new subject_id: params[:subject_id]
    if @exam.save
      add_questions_to_exam
      render json: {
        exam_id: @exam.id,
        question_number: @exam.subject.question_number,
        duration: @exam.subject.duration,
        score_pass: @exam.subject.score_pass,
        created_at: @exam.created_at
      }
    else
      render json: {notice: "Failed"}
    end
  end

  def show
    @questions = @exam.questions
    @exam.set_endtime if @exam.ready?
    if @exam.ready? || @exam.doing?
      render json: {endtime: @exam.endtime, list_question: handle_exam}
    else
      @list_answer = @exam.answers
      render json: {list_question: handle_view_exam}
    end
  end

  def update
    @exam.grade @exam.answers
    render json: {notice: "Update successfully"}
  end

  private
  def add_questions_to_exam
    question_number = @exam.subject.question_number
    questions = @exam.subject.questions
    if questions.length <= question_number
      @exam.add questions
      return
    end

    list_question_random = random_list(question_number, questions.length)
    list_question_random.each do |random_number|
      @exam.add questions[random_number]
    end
  end

  def add_answer_to_record
    params[:exam][:question].each do |key, value|
      case Question.find_by(id: key).question_type
      when Question.types[:multiple]
        value["id"].each do |id|
          @exam.add_record Answer.find_by id: id if id != ""
        end
      when Question.types[:single]
        @exam.add_record Answer.find_by id: value["id"] if value["id"] != ""
      end
    end
  end

  def find_exam
    @exam = Exam.find_by id: params[:id]
    return if @exam.present?

    render json: {notice: "Not found"}
  end

  def get_ques question
    ques = Hash.new
    ques[:id] = question.id
    ques[:question_type] = question.question_type
    ques[:question_content] = question.question_content
    if question.question_image.attached?
      ques[:img] = question.question_image_url
    end

    ques[:list_ans] = handle_answer question.answers
    ques
  end

  def handle_exam
    @questions.map do |question|
      get_ques question
    end
  end

  def handle_answer answers
    answers.map do |answer|
      ans = Hash.new
      ans[:id] = answer.id
      ans[:content] = answer.content
      ans
    end
  end

  def handle_view_exam
    @questions.map do |question|
      ques = get_ques(question)
      ques[:choosed] = @list_answer.map do |answer|
        answer.id if answer.question_id == question.id
      end.compact
      ques[:result] = result_of_question(@list_answer, question)
      ques
    end
  end

  def result_of_question user_answers, current_question
    result = ""
    case current_question.question_type
    when Question.types[:single]
      correct_answer = current_question.answers.find_by is_correct: true
      result = user_answers.include?(correct_answer) ? "correct" : "wrong"
    when Question.types[:multiple]
      result = result_of_mul current_question, user_answers
    end

    result
  end

  def result_of_mul current_question, user_answers
    result = "correct"
    correct_answers = current_question.answers.get_answers(true)
    choose = user_answers.where question_id: current_question.id
    if correct_answers.length != choose.length
      result = "wrong"
    else
      correct_answers.each do |answer|
        if choose.exclude? answer
          result = "wrong"
          break
        end
      end
    end
    result
  end

  def time_out
    exams = Exam.by_user(params[:user_id]).by_subject_id(params[:subject_id])

    exams.each do |exam|
      exam.grade(exam.answers) if exam.doing? && (exam.endtime <= Time.zone.now)
    end
  end
end
