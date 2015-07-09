class AddConcernsAndConcernedSpeciesData < ActiveRecord::Migration

  extend DataLoader
  
  def self.up
    load_data "concerns"
    load_data "concerned_species"
  end

  def self.down
    execute "DELETE FROM concerned_species WHERE id <= 45"
    execute "DELETE FROM concerns WHERE id <= 15"
  end
end
