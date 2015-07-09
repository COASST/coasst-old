class AddSpeciesAgesAndSpeciesPlumagesTables < ActiveRecord::Migration
  def self.up
    create_table :species_ages do |t|
      t.column :species_id, :integer, :null => false
      t.column :age_id,     :integer, :null => false
      t.column :admin_only, :boolean, :null => false, :default => false
    end

    create_table :species_plumages do |t|
      t.column :species_id, :integer, :null => false
      t.column :plumage_id, :integer, :null => false
      t.column :admin_only, :boolean, :null => false, :default => false
    end
  end

  def self.down
    drop_table :species_ages
    drop_table :species_plumages
  end
end
