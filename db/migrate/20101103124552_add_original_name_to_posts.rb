class AddOriginalNameToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :original_name, :string
  end

  def self.down
    remove_column :posts, :original_name
  end
end
