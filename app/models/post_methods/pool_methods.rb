module PostMethods
  module PoolMethods
    def p_parent
      self.pool_parent = true
      self.pool_child = false
      self.save
    end

    def p_child(pool_id)
      self.pool_parent = newly_added(pool_id)
      self.pool_child = true
      self.save
    end

    def out_of_pool
      self.pool_parent = false
      self.pool_child = false
      self.save
    end

    def newly_added(pool_id)
      return false if self.created_at < 1.day.ago

      tmp = Pool.find(pool_id).first
      tmp = Post.find tmp
      tmp = self.created_at - tmp.created_at
      tmp.abs > 1.day.to_i
    end

    # only adds to the parent picture
    def update_parent
      # add tags to parent, assuming there's only addition
    end

=begin
    # find all pool pictures and update parent tag
    def update_pool
      parent = find_parent
      pool = self.pools[0]
      pool = PoolPost.all :conditions => ["pool_id = ?", pool.id], :select => "post_id"

      pool.each do |post|
        # push the tags into the parent pool tag column
      end

      parent.save
    end
=end

  end
end
