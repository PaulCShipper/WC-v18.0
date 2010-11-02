class AdminController < ApplicationController
  before_filter :admin_only
  helper :avatar

  def index
    set_title "Admin"
  end

  def edit_user
    if request.post?
      @user = User.find_by_name(params[:user][:name])
      if @user.nil?
        flash[:notice] = "User not found"
        redirect_to :action => "edit_user"
        return
      end
      @user.level = params[:user][:level]

      if @user.save
        flash[:notice] = "User updated"
        redirect_to :action => "edit_user"
      else
        render_error(@user)
      end
    end
  end

  def reset_password
    if request.post?
      @user = User.find_by_name(params[:user][:name])
      
      if @user
        new_password = @user.reset_password
        flash[:notice] = "Password reset to #{new_password}"
        
        unless @user.email.blank?
          UserMailer.deliver_new_password(@user, new_password)
        end
      else
        flash[:notice] = "That account does not exist"
        redirect_to :action => "reset_password"
      end
    else
      @user = User.new
    end
  end

  def edit_avatar
    if request.post?
      @user = User.find_by_name(params[:user][:name])

      if @user
        @avatars = @user.avatars
      else
        flash[:notice] = "That account does not exist"
        redirect_to :action => "edit_avatar"
      end 
    elsif params[:id]
      @user = User.find_by_id(params[:id])
      if @user
        @avatars = @user.avatars
      else
        flash[:notice] = "That account does not exist"
        redirect_to :action => "edit_avatar"
      end
    else
      @user = User.new
    end
  end
end
