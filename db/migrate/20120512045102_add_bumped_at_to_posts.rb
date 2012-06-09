class AddBumpedAtToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :bumped_at, :datetime, :default => Time.now

    Post.all.each do |post|
      post.bumped_at = post.created_at
      post.save
    end
  end

  def self.down
    remove_column :posts, :bumped_at
  end
end
