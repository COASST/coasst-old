class AddVolunteersData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "volunteers"
  end

  def self.down
     execute("DELETE FROM volunteers WHERE id <= 1055")
  end
end
