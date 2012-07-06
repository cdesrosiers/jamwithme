require 'bcrypt'

class User
  include Mongoid::Document
  include BCrypt
  
  field :u, as: :username,        type: String
  field :h, as: :password_hash,   type: String
  field :r, as: :remember_token,  type: String

  index({ username: 1 }, unique: true)
  index({ remember_token: 1 })

  validates_presence_of :username
  validates_uniqueness_of :username

  before_save :create_remember_token

  def password
    return nil unless password_hash.present?
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def authenticate(submitted_password)
    password && password.is_password?(submitted_password)
  end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
