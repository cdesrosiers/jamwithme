class Message
  include Mongoid::Document
   
  field :c, as: :content,        type: String
end
