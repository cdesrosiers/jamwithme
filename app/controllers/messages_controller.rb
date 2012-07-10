class MessagesController < ApplicationController
  def create
    @message = Message.create!(params[:message])
    respond_to do |format|
      format.js
    end
  end
end
