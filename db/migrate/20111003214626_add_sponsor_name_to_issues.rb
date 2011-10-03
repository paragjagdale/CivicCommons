class AddSponsorNameToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :sponsor_name, :string
  end

  def self.down
    remove_column :issues, :sponsor_name
  end
end
