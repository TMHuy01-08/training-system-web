class Api::ExamsController < Api::ApiController
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
    exam = Exam.find_by id: params[:id]
    if exam.present?
      @questions = exam.questions
      exam.set_endtime if exam.ready?
      render json: {endtime: exam.endtime, list_question: handle_exam}
    else
      render json: {notice: "Error"}
    end
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

  def handle_exam
    @questions.map do |question|
      ques = Hash.new
      ques[:id] = question.id
      ques[:question_type] = question.question_type
      ques[:question_content] = question.question_content
      ques[:list_ans] = handle_answer question.answers
      ques
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
end
