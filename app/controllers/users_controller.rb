class UsersController < ApplicationController
  def partner
    if signed_in?
      respond_to { |format| format.js }
    else
      # remember that the user was trying to partner up
      session[:partner] = true
      respond_to { |format| format.js { render 'new' } }
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      if session[:partner] == true
        @partner = true
        session[:partner] = nil
      end
      respond_to { |format| format.js }
    else
      @error = @user.errors.full_messages[0] unless @user.errors.empty?
      respond_to { |format| format.js { render 'new_failure' } }
    end
  end
end
