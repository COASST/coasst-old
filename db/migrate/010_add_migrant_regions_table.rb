class AddMigrantRegionsTable < ActiveRecord::Migration
  def self.up
    create_table :migrant_regions do |t|
      t.column :code,       :string, :length => 20, :unique => true, :null => false
      t.column :name,       :string, :length => 50, :unique => true, :null => false
    end
    
    add_column :regions, :migrant_region_id, :integer
  end

  def self.down
    remove_column :regions, :migrant_region_id
    drop_table :migrant_regions
  end
  
end
