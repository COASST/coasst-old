class AddMigrantRegionsData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "migrant_regions"
    load_data "update_regions"
  end

  def self.down
    execute("UPDATE regions SET migrant_region_id = NULL")
    execute("DELETE FROM migrant_regions WHERE id <= 4")
  end
end
