class PagesController < ApplicationController
  def home
    if @show_dialog = !signed_in?
      @user = User.new
    end
  end
end
