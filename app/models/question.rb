class Question < ApplicationRecord
  NESTED_ATTRS = %i(id content is_correct _destroy).freeze
  QUESTION_ATTRS = %i(question_content question_image subject_id question_type)
                   .push(answers_attributes: NESTED_ATTRS)
  MIN_ANSWER = 2

  after_update :clean_storage
  after_save :clean_storage
  after_destroy :clean_storage

  enum type: {single: 0, multiple: 1}

  belongs_to :subject
  counter_culture :subject
  has_many :answers, dependent: :destroy
  has_many :exam_relationships, class_name: Relationship.name,
                                dependent: :destroy

  has_many :exams, through: :exam_relationships, source: :exam

  has_one_attached :question_image

  accepts_nested_attributes_for :answers,
                                allow_destroy: true,
                                reject_if: proc{|att| att["content"].blank?}

  validates :question_content, :subject_id, :question_type, presence: true
  validates :question_type, inclusion: {in: Question.types.values}
  validate :check_single_choice, on: %i(create update)
  validates :question_image, {content_type: {
                                in: Settings.image_type,
                                message: "must be a valid image format"
                              },
                              size: {
                                less_than: 5.megabytes,
                                message: "should be less than 5MB"
                              }}
  scope :get_by_type, ->(type){where question_type: type}
  scope :get_by_id, ->(id){where id: id}
  scope :by_subject, ->(id){where subject_id: id if id.present?}

  class << self
    def types_i18n
      types.map do |key, value|
        [I18n.t("question.type.#{key}"), value]
      end
    end
  end

  def type_i18n type_id
    type = Question.types.keys[type_id]
    I18n.t("question.type.#{type}")
  end

  class << self
    def import file
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        Question.create! handle_data row
      end
    end

    def handle_data row
      row[:subject_id] = (Subject.find_by name: row["subject"]).id
      row[:question_content] = row["question content"].strip
      row[:question_type] = handle_type row["question type"]
      row[:answers_attributes] = handel_excel row["answers attributes"].strip
      row.delete "subject"
      row.delete "question type"
      row.delete "question content"
      row.delete "answers attributes"
      row
    end

    def handle_type question_type
      case question_type
      when Question.types[:single]
        Question.types[:single]
      when Question.types[:multiple]
        Question.types[:multiple]
      end
    end

    def open_spreadsheet file
      case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
      end
    rescue StandardRecord
      Rails.logger = Logger.new "Unknown file type"
    end

    protected

    def handel_excel row
      row.split(",").map do |attribute|
        attribute_hash = Hash.new
        arr_option = attribute.split(":")
        attribute_hash[:content] = arr_option[0]
        attribute_hash[:is_correct] = arr_option[1]
        attribute_hash
      end
    end
  end

  def get_answers
    answers.map do |answer|
      "#{answer.content}:#{answer.is_correct}"
    end.join(",")
  end

  def question_image_path
    ActiveStorage::Blob.service.path_for(question_image.key)
  end

  private
  def check_valid_question
    return true if answers.size >= MIN_ANSWER

    errors.add(:question_content, :not_enough_answer)
  end

  def check_single_choice
    check_valid_question
    correct_count = answers.map(&:is_correct).count(true)
    return true if correct_count.positive? &&
                   question_type == Question.types[:multiple]
    return true if correct_count == Settings.single_correct_answer &&
                   question_type == Question.types[:single]

    errors.add(:answers, :not_valid_correct_answer_number)
  end

  def clean_storage
    Dir.glob(Rails.root.join("storage/**/*").to_s)
       .sort_by(&:length).reverse.each do |x|
      Dir.rmdir(x) if File.directory?(x) && Dir.empty?(x)
    end
  end
end
