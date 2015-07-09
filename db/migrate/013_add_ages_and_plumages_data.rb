class AddAgesAndPlumagesData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "ages"
    load_data "plumages"
  end

  def self.down
    execute("DELETE FROM ages WHERE id <= 4")
    execute("DELETE FROM plumages WHERE id <= 14")
  end
end
