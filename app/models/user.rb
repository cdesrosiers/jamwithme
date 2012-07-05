class User
  include MongoMapper::Document
  plugin MongoMapper::Devise

  devise :registerable, :database_authenticatable, :recoverable, :rememerable,
    :trackable, :validatable 

  key :username, String
end
