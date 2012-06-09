class NewStatus < ActiveRecord::Migration
  def self.up
    # temp status
    add_column :posts, :old_status, :integer

    # setting up and using backup as hidden
    Post.all.each do |post|
      if not post.has_tag?("backup").nil?
        post.old_status = 3
      elsif post.status == "deleted"
        post.old_status = 0
      elsif post.status == "flagged"
        post.old_status = 1
      elsif post.is_pending?
        post.old_status = 2
      else
        post.old_status = 4
      end
      post.save
    end

    transaction do
      # Extending enum type for status
      execute "drop index post_status_idx"
      execute "alter table posts drop column status"
      execute "drop type post_status"
  
      execute "create type post_status as enum ('deleted', 'flagged', 'pending', 'hidden', 'active')"
      execute "alter table posts add column status post_status not null default 'active'"
      execute "create index post_status_idx on posts (status) where status < 'active'"
  
      # Quality enum
      execute "create type post_quality as enum ('doodle', 'normal', 'high')"
      execute "alter table posts add column quality post_quality not null default 'normal'"
    end

    # setting new status with temp
    Post.all.each do |post|
      if post.old_status == 3
        post.status = "hidden"
      elsif post.old_status == 0
        post.status = "deleted"
      elsif post.old_status == 1
        post.status = "flagged"
      elsif post.old_status == 2
        post.status = "pending"
      else
        post.status = "active"
      end
      post.save
    end

    # done
    remove_column :posts, :old_status
  end

  def self.down
    #raise IrreversibleMigration
  end
end
