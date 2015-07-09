class VolunteerStatus < ActiveRecord::Migration
  def self.up
    add_column :volunteers, :has_account, :boolean, :default => false
  end

  def self.down
    remove_column :volunteers, :has_account
  end
end
