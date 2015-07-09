class AddFootTypeFamiliesTable < ActiveRecord::Migration
  def self.up
    create_table :foot_type_families do |t|
      t.column :toe_type_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :description, :string
      t.column :active, :boolean, :default => true
    end
  end

  def self.down
    drop_table :foot_type_families
  end
end
