class AddSpeciesData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "species"
  end

  def self.down
    execute("DELETE FROM species WHERE id <= 133")
  end
end
