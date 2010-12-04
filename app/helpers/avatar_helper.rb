module AvatarHelper
  def get_avatar(id, options ={})
    return "" unless id
    show_avatar(Avatar.find(id), options)
  end

  def show_avatar(avatar, options ={})
    unless avatar and avatar.can_be_seen_by?(@current_user)
      return ""
    end

    img = %Q{<img src="#{CONFIG["url_base"]}/avatars/#{avatar.src}" }

    if avatar.id == avatar.user.avatar_id and options[:default]
      img += %Q{class="avatar-active"}
    elsif avatar.show
      img += %Q{class="avatar"}
    else
      img += %Q{class="avatar-deleted"}
    end

    if options[:label]
      img += %Q{ alt="#{avatar.label}" title="#{avatar.label}"}
    end

    img += ">"

    return img
  end

  def link_avatar(avatar, link, options = {})
    unless avatar and avatar.can_be_seen_by?(@current_user)
      return ""
    end
    return link_to show_avatar(avatar, options), link
  end

  def select_avatar(type)
    if @current_user.is_anonymous?
      return ""
    end

    selector = case type
      when "comment" then collection_select(:comment, :avatar_id, @current_user.avatars.all(:conditions => "show = true"), 'id', 'label', :include_blank => "(defaul)")
      when "forum_post" then collection_select(:forum_post, :avatar_id, @current_user.avatars.all(:conditions => "show = true"), 'id', 'label', :include_blank => "(defaul)")
    end
    return selector
  end
end
