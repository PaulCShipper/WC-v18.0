class AddDetailsToPostTagHistory < ActiveRecord::Migration
  def self.up
    add_column :post_tag_histories, :title, :text
    add_column :post_tag_histories, :description, :text
    PostTagHistory.update_all "title = '', description = ''"
  end

  def self.down
    remove_column :post_tag_histories, :description
    remove_column :post_tag_histories, :title
  end
end
