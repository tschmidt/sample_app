class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    build_error_message(params)
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to user
    else
      redirect_to signin_path, flash: { error: @error_message.join('. ') }
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end

private

  def build_error_message(params)
    @error_message = []
    case
    when params[:session][:email].blank?
      @error_message << "An email is required to login"
    when params[:session][:password].blank?
      @error_message << "A password is required to login"
    when !User.exists?(email: params[:session][:email])
      @error_message << "It doesn't look like that email is registered yet. Perhaps you meant to sign up instead?"
    end
  end
  
end
