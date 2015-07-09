class AddToeTypesData < ActiveRecord::Migration

  extend DataLoader

  def self.up
    load_data "toe_types"
  end

  def self.down
    execute("DELETE FROM toe_types WHERE id <= 6")
  end
end
