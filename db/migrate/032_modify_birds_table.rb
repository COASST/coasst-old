class ModifyBirdsTable < ActiveRecord::Migration
  def self.up
    add_column :birds, :tie_other, :string, :length => 50
  end

  def self.down
    remove_column :birds, :tie_other
  end
end
