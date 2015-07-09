class AddSpeciesAgesAndSpeciesPlumagesData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "species_ages"
    load_data "species_plumages"
  end

  def self.down
    execute("DELETE FROM species_plumages WHERE species_id <= 131")
    execute("DELETE FROM species_ages WHERE species_id <= 131")
  end
end
