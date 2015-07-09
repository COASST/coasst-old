class AddFootTypeFamiliesData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "foot_type_families"
  end

  def self.down
    execute("DELETE FROM foot_type_families WHERE id IS NOT NULL")
  end
end
