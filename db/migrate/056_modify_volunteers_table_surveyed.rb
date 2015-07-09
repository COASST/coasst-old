class ModifyVolunteersTableSurveyed < ActiveRecord::Migration
  def self.up
    # training intake data
    add_column :volunteers, :last_surveyed_date, :date
  end

  def self.down
    remove_column :volunteers, :last_surveyed_date
  end
end
