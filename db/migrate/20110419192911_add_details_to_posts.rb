class AddDetailsToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :title, :text, :default => ""
    add_column :posts, :description, :text, :default => ""
    Post.update_all "title = '', description = ''"
  end

  def self.down
    remove_column :posts, :description
    remove_column :posts, :title
  end
end
