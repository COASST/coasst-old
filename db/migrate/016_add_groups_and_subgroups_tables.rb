class AddGroupsAndSubgroupsTables < ActiveRecord::Migration
  def self.up   
    create_table :groups do |t|
      t.column :foot_type_family_id, :integer, :null => false
      t.column :name,                :string, :null => false
      t.column :code,                 :string, :limit => 5,  :null => false
      t.column :name,                :string, :null => false
      t.column :active,               :boolean, :default => true
      t.column :description,         :string, :null => true
      t.column :composite,          :boolean, :default => false
    end
    
    create_table :subgroups do |t|
      t.column :group_id, :integer, :null => false
      t.column :name,     :string, :null => false
    end

  end

  def self.down
    drop_table :subgroups
    drop_table :groups
  end
end
