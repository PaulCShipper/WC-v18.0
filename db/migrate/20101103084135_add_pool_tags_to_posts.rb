class AddPoolTagsToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :pool_tags, :string
    add_column :posts, :pool_parent, :boolean
    add_column :posts, :pool_child, :boolean

    execute "alter table posts add column pool_index tsvector"
    execute "update posts set pool_index = to_tsvector('danbooru', pool_tags)"
    execute "create index index_posts_on_pool_index on posts using gin(pool_index)"

    execute "create trigger trg_posts_pool_index_update before insert or update on posts for each row execute procedure tsvector_update_trigger(pool_index, 'public.danbooru', pool_tags)"
  end

  def self.down
    remove_column :posts, :pool_tags
  end
end
