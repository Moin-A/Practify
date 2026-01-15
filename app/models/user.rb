class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :role_users, dependent: :destroy
  has_many :roles, through: :role_users
  has_one :user_profile, dependent: :destroy
  validates :email_address, presence: true, uniqueness: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_initialize :set_default_role, if: :new_record?

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
  private
  def set_default_role
    role = Role.find_by(name: "Client")
    self.roles << role if role
  end
end
