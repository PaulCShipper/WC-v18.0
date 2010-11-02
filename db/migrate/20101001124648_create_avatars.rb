class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars do |t|
      t.string :src
      t.boolean :show, :default => true
      t.integer :user_id
      t.string :label
      t.string :ip_addr

      t.timestamps
    end

    add_column :users, :avatar_id, :integer
    add_column :comments, :avatar_id, :integer
    add_column :forum_posts, :avatar_id, :integer

  end

  def self.down
    drop_table :avatars
    remove_column :users, :avatar_id
    remove_column :comments, :avatar_id
    remove_column :forum_posts, :avatar_id
  end
end
