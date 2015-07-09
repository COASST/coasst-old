class AddGroupsAndSubgroupsData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "groups"
    load_data "subgroups"
  end

  def self.down
    execute("DELETE FROM subgroups WHERE id IS NOT NULL")
    execute("DELETE FROM groups WHERE id IS NOT NULL")
  end
end
