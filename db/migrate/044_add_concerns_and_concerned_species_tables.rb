class AddConcernsAndConcernedSpeciesTables < ActiveRecord::Migration
  def self.up

    create_table :concerns do |t|
      t.column :state_id,   :integer
      t.column :code,       :string, :limit => 5, :unique => true
      t.column :name,       :string, :unique => true, :null => false
    end

    create_table :concerned_species, :id => false do |t|
      t.column :concern_id, :integer
      t.column :species_id, :integer
    end

  end

  def self.down
    drop_table :concerned_species
    drop_table :concerns
  end
end
