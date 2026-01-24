class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :role_users, dependent: :destroy
  has_many :roles, through: :role_users
  has_one :user_profile, dependent: :destroy
  has_one :calendar, dependent: :destroy, inverse_of: :user
  has_many :appointments, dependent: :destroy
  validates :email_address, presence: true, uniqueness: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_initialize :set_default_role, if: :new_record?
  after_create :create_user_profile

  def super_admin?
    roles.exists?(name: "SuperAdmin")
  end

  def client?
    roles.exists?(name: "Client")
  end

  def therapist?
    roles.exists?(name: "therapist")
  end

  def admin?
    roles.exists?(name: "admin")
  end

  def calendar
    super || CalendarManager.create_default_calendar(self)
  end

  private
  def set_default_role
    role = Role.find_by(name: "Client")
    self.roles << role if role
  end

  def create_user_profile
    UserProfile.find_or_create_by!(user_id: self.id, first_name: email_address.split("@").first, last_name: email_address.split("@").last)
  end
end
