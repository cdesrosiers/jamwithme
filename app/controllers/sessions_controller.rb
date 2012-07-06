class SessionsController < ApplicationController
  before_filter :signed_out_user, only: [:new, :create]
  before_filter :signed_in_user, only: [:destroy]
  
  def create
    @user = User.find_by(username: params[:session][:username])
    if @user && @user.authenticate(params[:session][:password])
      sign_in user
      respond_to { |format| format.js }
    else
      respond_to { |format| format.js { render 'new' } }
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private

    def signed_out_user
      redirect_to root_path if signed_in?
    end
    
    def signed_in_user
      unless signed_in?
        redirect_to root_path
      end
    end
end
