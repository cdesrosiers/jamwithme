class UsersController < ApplicationController
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      respond_to { |format| format.js }
    else
      @error = @user.errors.full_messages[0] unless @user.errors.empty?
      respond_to { |format| format.js { render 'new' } }
    end
  end
end
