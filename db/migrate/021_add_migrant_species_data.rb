class AddMigrantSpeciesData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "migrant_species"
  end

  def self.down
     execute("DELETE FROM migrant_species WHERE id <= 118")
  end
end
