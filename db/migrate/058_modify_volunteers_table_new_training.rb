class ModifyVolunteersTableNewTraining < ActiveRecord::Migration
  def self.up
    # training intake data
    add_column :volunteers, :hazwoper_trained, :boolean, :default => false
  end

  def self.down
    remove_column :volunteers, :hazwoper_trained
  end
end
