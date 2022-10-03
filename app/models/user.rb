class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :exams, dependent: :destroy

  USER_ATTRS = %i(name email password password_confirmation remember_me).freeze
  enum role_id: {user: 0, admin: 1}
  before_save :downcase_email

  validates :email, presence: true,
                    length: {minium: Settings.min_length,
                             maximum: Settings.max_length},
                    format: {with: Settings.email_regex},
                    uniqueness: {case_sensitive: false}

  validates :name, presence: true,
                   length: {minium: Settings.min_length,
                            maximum: Settings.max_length}

  validates :password, presence: true,
                       length: {minimum: Settings.password_min_length,
                                maximum: Settings.password_max_length},
                       allow_nil: true

  scope :this_month, ->{where(created_at: Time.zone.today.all_month)}

  def activate_or_inactive
    update activated: !activated, activated_at: Time.zone.now
  end

  private

  def downcase_email
    email.downcase!
  end
end
