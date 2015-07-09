class AddSurveysTable < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      t.column :beach_id,         :integer, :null => false
      t.column :code,             :string, :limit => 17, :null => false
      t.column :survey_date,      :date, :null => false
      t.column :start_time,       :time, :null => false
      t.column :end_time,         :time, :null => false
      t.column :duration,         :integer # composition, start - end (minutes)
      t.column :weather,          :string
      t.column :oil_present,      :boolean
      t.column :oil_frequency,    :string  # could be numeric, logaritmic scaled
      t.column :oil_sheen,        :boolean
      t.column :oil_tarballs,     :boolean
      t.column :oil_goopy,        :boolean
      t.column :oil_mousse,       :boolean
      t.column :oil_comment,      :text
      t.column :wood_present,     :boolean
      t.column :wood_size,        :string # could be numeric
      t.column :wood_continuity,  :string
      t.column :wood_zone,        :string
      t.column :wrack_present,    :boolean
      t.column :wrack_width,      :string
      t.column :wrack_continuity, :string
      # this is redundant with tracks table, but the field must be selected
      # in the form, so push it into the table for validation
      t.column :tracks_present,   :boolean 
      t.column :comments,         :text
      t.column :created_on,       :datetime
      t.column :updated_on,       :datetime
      t.column :verified,         :boolean
      t.column :is_survey,        :boolean, :default => true
      t.column :is_complete,      :boolean, :default => false
    end
  end

  def self.down
    drop_table :surveys
  end
end
