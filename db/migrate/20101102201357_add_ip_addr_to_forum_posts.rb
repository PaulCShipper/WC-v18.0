class AddIpAddrToForumPosts < ActiveRecord::Migration
  def self.up
    add_column :forum_posts, :ip_addr, :string
  end

  def self.down
    remove_column :forum_posts, :ip_addr
  end
end
