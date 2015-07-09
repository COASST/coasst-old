class ModifyBirdsTableAddVerification < ActiveRecord::Migration
  def self.up
    add_column :birds, :identification_level_family, :string
    add_column :birds, :identification_level_species, :string
    add_column :birds, :identification_level_group, :string
  end

  def self.down
    remove_column :birds, :identification_level_family
    remove_column :birds, :identification_level_species
    remove_column :birds, :identification_level_group
  end
end
