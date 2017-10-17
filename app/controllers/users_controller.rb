class UsersController < ApplicationController

  skip_before_action :require_login, only: [:login, :logout]
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def login
    auth_hash = request.env['omniauth.auth']
    if auth_hash['uid']
      user = User.find_by(provider: params[:provider], uid: auth_hash['uid'])
      if user.nil?
        user = User.from_auth_hash(params[:provider], auth_hash)
        save_and_flash(user)
      else
        flash[:status] = :success
        flash[:result_text] = "Logged in successfully as returning user #{user.username}"
      end
      session[:user_id] = user.id
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not create user"
    end
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "You have been logged out"
    redirect_to root_path
  end
end
