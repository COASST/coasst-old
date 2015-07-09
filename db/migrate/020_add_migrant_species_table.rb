class AddMigrantSpeciesTable < ActiveRecord::Migration
  def self.up
    create_table :migrant_species do |t|
      t.column :species_id,         :integer, :null => false
      t.column :migrant_region_id,  :integer, :null => false
      t.column :status,             :text, :default => 'unknown'
    end
  end

  def self.down
    drop_table :migrant_species
  end
end
