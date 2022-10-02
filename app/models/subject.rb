class Subject < ApplicationRecord
  has_many :exams, dependent: :destroy
  has_many :questions, dependent: :destroy

  SUBJECT_ATTRS = %i(name description question_number duration
                                                      score_pass).freeze

  validates :name, :duration, :question_number, :score_pass, presence: true
  validates :name, uniqueness: {case_sensitive: false, message: :unique}
  validates :description, length: {maximum: Settings.description_max_length}
  validates :duration, :question_number, :score_pass,
            numericality: {only_integer: true}
  validate :check_score_pass, on: %i(create update)
  scope :this_month, ->{where(created_at: Time.zone.today.all_month)}

  private
  def check_score_pass
    return unless score_pass.present? && question_number.present?
    return if score_pass <= question_number

    errors.add(:score_pass, :cannot_greater)
  end
end
