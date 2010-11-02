class AvatarController < ApplicationController
  before_filter :admin_only, :only => :hide

  def show
    @avatar = Avatar.find(params[:id])
  end
  
  def edit
    @avatar = Avatar.find(params[:id])
  end

  def create
    begin
      @avatar = Avatar.new(params[:avatar].merge(:user_id => @current_user.id, :ip_addr => request.remote_ip)) || Avatar.new
      if @avatar.save
        flash[:notice] = "You have succesfully uploaded a new avatar."
      else
        flash[:notice] = @avatar.errors.full_messages || "Internal error. Try uploading again."
      end
      redirect_to :controller => "user", :action => "avatar", :id => @current_user.id
    rescue
      respond_to_error("", {:controller => "user", :action => "avatar", :id => @current_user.id})
      return
    end
  end

  def update
    @avatar = Avatar.find(params[:id])

    if @current_user.id == @avatar.user.id
      @avatar.update_attribute(:label, params[:label])

      if params[:default]
        @avatar.user.update_attribute(:avatar_id, @avatar.id)
      end

      flash[:notice] = "You have successfully edit your avatar"
      redirect_to :controller => "user", :action => "avatar", :id => @avatar.user.id
    else
      respond_to_error("You do not own this avatar", {:controller => "user", :action => "avatar", :id => @avatar.user.id})
    end
  end

  # some small problems with this
  def hide
    avatar = Avatar.find(params[:id])
    avatar.hide_avatar
    redirect_to :controller => "admin", :action => "edit_avatar", :id => avatar.user.id
  end
end
