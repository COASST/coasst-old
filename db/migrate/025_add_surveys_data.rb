class AddSurveysData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "surveys"
  end

  def self.down
     execute("DELETE FROM surveys WHERE id <= 12519")
  end
end
