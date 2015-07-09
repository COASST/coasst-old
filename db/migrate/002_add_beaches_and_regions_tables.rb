class AddBeachesAndRegionsTables < ActiveRecord::Migration
  def self.up

    create_table :states do |t|
      t.column :prefix, :string, :limit => 2, :unique => true, :null => false
      t.column :name, :string, :unique => true, :null => false
    end

    create_table :regions do |t|
      t.column :state_id,   :integer
      t.column :code,       :string, :limit => 5, :unique => true
      t.column :name,       :string, :unique => true, :null => false
    end

    create_table :counties do |t|
      t.column :state_id, :integer
      t.column :name,     :string, :unique => true, :null => false
      t.column :division, :string, :default => 'county' # county or borough
    end

    create_table :beaches do |t|
      t.column :region_id,          :integer
      t.column :county_id,          :integer
      t.column :state_id,            :integer
      t.column :code,                :string, :limit => 10, :null => false, :unique => true
      t.column :name,                :string, :limit => 50, :null => false
      t.column :description,        :text
      t.column :start_description,  :text
      t.column :turn_description,    :text
      t.column :city,              :string, :limit => 50
      t.column :latitude,          :decimal,
                                  :precision => 12, :scale => 8
      t.column :longitude,        :decimal,
                                  :precision => 13, :scale => 8
      t.column :turn_latitude,    :decimal,
                                  :precision => 12, :scale => 8
      t.column :turn_longitude,    :decimal,
                                  :precision => 13, :scale => 8
      t.column :location_notes,    :text # denormalized, may need model testing (i.e. is valid?)
      t.column :length,            :decimal,
                                  :precision => 7, :scale => 5
      t.column :width,            :string, :limit => 10
      t.column :substrate,        :string, :limit => 20
      t.column :orientation,      :string, :limit => 10
      t.column :monitored,        :boolean, :default => true
      t.column :access,            :string, :length => 20
      t.column :ownership,        :string, :length => 50
      t.column :geomorphology,    :string, :length => 20 # constraints in model per rail-foo
      t.column :vehicles_allowed,  :boolean, :default => false
      t.column :vehicles_start,   :integer
      t.column :vehicles_end,     :integer
      t.column :dogs_allowed,     :boolean, :default => false
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end
  end

  def self.down
    drop_table :beaches
    drop_table :regions
    drop_table :counties
    drop_table :states
  end
end
