class UpdatePoolRelation < ActiveRecord::Migration
  def self.up

    error_count = 0
    errors = []

    PoolPost.all.each do |pp|
      unless errors.include?(pp.post_id)
        post = Post.find pp.post_id
        if post.pools.count > 1
          errors << post.id
          error_count += 1
          post.flag! "Post must have only one pool, pick one", User.find(1)
        elsif pp.sequence == 0
          post.p_parent
        else
          post.p_child
        end
      end
    end

    say "Pool relationship updated"
      
    if error_count > 0
      say "Need to manual correct #{error_count} posts", true
    end
  end

  def self.down
  end
end
