module PostMethods
  module StatusMethods
    def delete!
      give_favorites_to_parent

      # my edit
      update_attribute(:bumped_at, created_at)
      first_history = PostTagHistory.first :conditions => ["post_id = ?", id]
      update_attribute(:user_id, first_history.user_id)

      update_attribute(:status, "deleted")
      Post.update_has_children(parent_id) if parent_id
      flag_detail.update_attributes(:is_resolved => true) if flag_detail
    end

    def status=(s)
      return if s == status
      write_attribute(:status, s)
      touch_change_seq!
    end
  
    def undelete!(user_id)
      execute_sql("UPDATE posts SET status = ?, approver_id = ? WHERE id = ?", "active", user_id, id)
      Post.update_has_children(parent_id) if parent_id
    end
    
    Post::STATUSES.each do |x|
      define_method("is_#{x}?") do
        return status == x
      end
    end
  end
end
