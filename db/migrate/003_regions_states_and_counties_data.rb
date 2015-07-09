class RegionsStatesAndCountiesData < ActiveRecord::Migration

  extend DataLoader

  def self.up
    load_data "states"
    load_data "regions"
    load_data "counties"  
  end

  # data only migration
  def self.down
    execute("DELETE FROM regions WHERE id is not NULL")
    execute("DELETE FROM counties WHERE id is not NULL")
    execute("DELETE FROM states WHERE id is not NULL")
  end
end
