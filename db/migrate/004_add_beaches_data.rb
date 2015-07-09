class AddBeachesData < ActiveRecord::Migration

  extend DataLoader

  def self.up
    load_data "beaches"
  end

  # data only migration
  def self.down
    execute("DELETE FROM beaches WHERE id is not NULL")
  end
end

