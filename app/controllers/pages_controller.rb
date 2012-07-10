class PagesController < ApplicationController
  def home
    @user = User.new
    @messages = Message.all
  end
end
