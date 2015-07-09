class AddSpeciesTable < ActiveRecord::Migration
  def self.up
   # all length columns in Centimeters (cm).  min: 0 and max: 999 are unknown true values
   create_table :species do |t|
      t.column :foot_type_family_id, :integer, :null => false
      t.column :group_id,            :integer, :null => false
      t.column :subgroup_id,         :integer
      t.column :code,                :string, :null => false
      t.column :name,                :string, :null => false
      t.column :sex_difference,      :boolean, :default => false
      t.column :tarsus_min,          :integer, :null => false, :default => 0
      t.column :tarsus_max,          :integer, :null => false, :default => 999
      t.column :wing_min,            :integer, :null => false, :default => 0
      t.column :wing_max,            :integer, :null => false, :default => 999
      t.column :bill_min,            :integer, :null => false, :default => 0
      t.column :bill_max,            :integer, :null => false, :default => 999
      t.column :active,              :boolean, :default => true
      t.column :verification_source, :string
    end
  end

  def self.down
    drop_table :species
  end
end
