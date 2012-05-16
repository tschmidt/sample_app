class UsersController < ApplicationController
  before_filter :redirect_signed_in_user, only: [:new, :create]
  before_filter :require_sign_in,         only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,            only: [:edit, :update]
  before_filter :admin_user,              only: :destroy
  
  def index
    @users = User.order('name ASC').paginate(page: params[:page]).all
  end
  
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      redirect_to @user, flash: { success: 'Welcome to the Sample App!' }
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(params[:user])
      sign_in @user
      redirect_to @user, flash: { success: "Profile updated" }
    else
      render :edit
    end
  end
  
  def destroy
    user = User.find(params[:id])
    if current_user?(user)
      redirect_to user, alert: "You cannot remove your own account"
    else
      user.destroy
      redirect_to users_path, flash: { success: 'User has been deleted' }
    end
  end

private

  def require_sign_in
    if not signed_in?
      store_location
      redirect_to signin_path, notice: "Please sign in."
    end
  end
  
  def correct_user
    @user = User.find(params[:id])
    redirect_to root_path if not current_user?(@user)
  end
  
  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
  
  def redirect_signed_in_user
    if signed_in?
      redirect_to root_path
    end
  end
end
