class AddToeTypesTable < ActiveRecord::Migration
  def self.up
    
    create_table :toe_types do |t|
      t.column :code,   :string, :limit => 5, :null => false 
      t.column :name,   :string, :limit => 20, :null => false
      t.column :active, :boolean, :default => true
    end
  end

  def self.down
    drop_table :toe_types
  end
end
