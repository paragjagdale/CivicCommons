class AddExcludeFromRecentOnConversations < ActiveRecord::Migration
  def self.up
    add_column :conversations, :exclude_from_most_recent, :boolean, :default => false
  end

  def self.down
    remove_column :conversations, :exclude_from_most_recent
  end
end
