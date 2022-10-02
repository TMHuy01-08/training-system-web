class Exam < ApplicationRecord
  ANSWER_ATTRS = %i(question_id answer_id).freeze
  EXAM_ATTRS = %i(question: ANSWER_ATTRS).freeze

  enum status: {ready: 0, doing: 1, completed: 2, failed: 3, passed: 4}

  belongs_to :user
  belongs_to :subject
  counter_culture :subject

  has_many :question_relationships, class_name: Relationship.name,
                                    dependent: :destroy
  has_many :questions, through: :question_relationships, source: :question
  has_many :answer_relationships, class_name: Record.name, dependent: :destroy
  has_many :answers, through: :answer_relationships, source: :answer

  validates :user_id, presence: true
  validates :subject_id, presence: true

  scope :newest, ->{order(created_at: :desc)}
  scope :by_user, ->(user_id){where(user_id: user_id)}
  scope :by_subject_id, ->(id){where(subject_id: id)}
  scope :by_statuses, ->(statuses){where(status: statuses)}
  scope :this_month, ->{where(created_at: Time.zone.today.all_month)}
  delegate :name, to: :subject, prefix: true

  ransacker :created_at, type: :date do
    Arel.sql("date(created_at)")
  end

  def add question
    questions << question
  end

  def add_record answer
    answers << answer
  end

  def status_i18n type
    I18n.t("exam.status.#{type}")
  end

  def check_result exam
    if exam.ready? || exam.doing?
      ""
    else
      "#{exam.result} / #{exam.subject.question_number}"
    end
  end

  def grade user_select
    result = self.result
    questions = self.questions

    multi = questions.get_by_type Question.types[:multiple]
    have_multi_choice = multi.present?
    result = grading_multi_choice result, user_select if have_multi_choice

    single = questions.get_by_type Question.types[:single]
    have_single_choice = single.present?
    if have_single_choice
      list_single = Question.get_by_type Question.types[:single]
      result = grading_single_choice list_single, result, user_select
    end

    update_status result
  end

  def set_endtime
    update endtime: Time.zone.now + subject.duration.minutes,
           status: Exam.statuses[:doing]
  end

  private

  def grading_single_choice list_single, result, list
    correct_answers = list_single.map do |question|
      question.answers.find_by is_correct: true
    end

    user_answers = get_user_answers Question.types[:single], list
    user_answers.compact!

    user_answers.each do |answer|
      result += 1 if correct_answers.include? answer
    end
    result
  end

  def get_user_answers question_type, list
    list.map do |answer|
      answer if answer.question.question_type == question_type
    end
  end

  def grading_multi_choice result, list
    user_answers = get_user_answers Question.types[:multiple], list
    user_answers.compact!

    handle_result result, user_answers
  end

  def handle_result result, user_answers
    current_check = Question.new

    user_answers.each do |answer|
      current_question = answer.question
      next if current_question == current_check

      correct_answers = current_question.answers.where(is_correct: true)
      answers_selected = user_answers.map do |select|
        select if select.question == current_question
      end
      answers_selected.compact!

      next unless correct_answers.length == answers_selected.length

      check = is_correct_question? correct_answers, answers_selected

      result += 1 if check
      current_check = current_question
    end
    result
  end

  def is_correct_question? correct_answers, answers_selected
    is_correct = true
    answers_selected.each do |selected|
      if correct_answers.exclude? selected
        is_correct = false
        break
      end
    end
    is_correct
  end

  def update_status result
    update result: result
    current_subject = subject
    if result >= current_subject.score_pass
      update status: Exam.statuses[:passed]
    else
      update status: Exam.statuses[:failed]
    end
  end
end
