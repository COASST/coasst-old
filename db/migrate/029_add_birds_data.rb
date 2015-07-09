class AddBirdsData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "birds"
  end

  def self.down
     execute("DELETE FROM birds WHERE id <= 27573")
  end
end
