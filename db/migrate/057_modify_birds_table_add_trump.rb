class ModifyBirdsTableAddTrump < ActiveRecord::Migration
  def self.up
    add_column :birds, :identification_trump, :string
  end

  def self.down
    remove_column :birds, :identification_trump
  end
end
