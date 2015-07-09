class AddBirdsTable < ActiveRecord::Migration
  def self.up
    create_table :birds do |t|
      t.column :survey_id,            :integer, :null => false
      t.column :species_id,           :integer
      t.column :group_id,             :integer
      t.column :subgroup_id,          :integer
      t.column :foot_type_family_id,  :integer
      t.column :plumage_id,           :integer
      t.column :age_id,               :integer

      # metadata
      t.column :code,                 :string, :unique => true
      t.column :where_found,          :string
      t.column :refound,              :boolean
      t.column :collected,            :boolean
      t.column :collected_comment,    :text
      t.column :photo_count,          :integer

      # physical characteristics
      t.column :foot_condition,       :string
      t.column :intact,               :boolean
      t.column :head,                 :boolean
      t.column :breast,               :boolean
      t.column :eyes,                 :string
      t.column :feet,                 :string
      t.column :wings,                :string
      t.column :entangled,            :string
      t.column :entangled_comment,    :text
      t.column :oil,                  :boolean
      t.column :oil_comment,          :text
      t.column :sex,                  :string
      t.column :bill_length,          :decimal, :scale => 2, :precision => 8
      t.column :wing_length,          :decimal, :scale => 2, :precision => 8
      t.column :tarsus_length,        :decimal, :scale => 2, :precision => 8

      # identification data
      t.column :tie_location,         :string
      t.column :tie_location_comment, :text # for the case of multiple ties
      # composite (closest, middle, farthest), use string or we drop lead zeroes
      t.column :tie_number,           :string
      # these three columns map to colors
      t.column :tie_color_closest,    :integer
      t.column :tie_color_middle,     :integer
      t.column :tie_color_farthest,   :integer

      # verification data
      t.column :is_bird,              :boolean, :default => true
      t.column :comment,              :text
      t.column :verification_comment, :text
      t.column :verified,             :boolean, :default => false
      t.column :verification_method,  :string
      t.column :original_data,      :text
      t.column :identification_level, :string
      t.column :created_on,           :datetime
      t.column :updated_on,           :datetime
    end
  end

  def self.down
    drop_table :birds
  end
end
