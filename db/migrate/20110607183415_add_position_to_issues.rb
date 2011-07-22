class AddPositionToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :position, :integer
  end

  def self.down
    remove_column :issues, :position
  end
end
