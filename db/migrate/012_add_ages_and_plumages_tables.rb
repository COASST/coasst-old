class AddAgesAndPlumagesTables < ActiveRecord::Migration
  def self.up
    create_table :plumages do |t|
      t.column :name,       :string, :null => false
      t.column :code,       :string, :null => false, :limit => 2
      t.column :admin_only, :boolean,  :default => false, :null => false
    end
    
    create_table :ages do |t|
      t.column :name, :string, :null => false
    end
  end

  def self.down
    drop_table :plumages
    drop_table :ages
  end
  
end
