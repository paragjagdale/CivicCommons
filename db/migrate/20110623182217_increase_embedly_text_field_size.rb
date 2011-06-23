class IncreaseEmbedlyTextFieldSize < ActiveRecord::Migration
  def self.up
    change_column :top_items, :activity_cache, :longtext
    change_column :contributions, :embedly_code, :longtext
  end

  def self.down
    change_column :top_items, :activity_cache, :text
    change_column :contributions, :embedly_code, :text
  end
end
