class UsersController < ApplicationController
  def create
    @user = User.new(params[:user])
    if @user.save
      respond_to do |format|
        format.js
      end
    else
      #failure
    end
  end
end
