class AddSurveyTracksAndSurveyVolunteersTables < ActiveRecord::Migration
  def self.up
    create_table :survey_tracks do |t|
      t.column :survey_id,	:integer, :null => false
      t.column :track_type, :string, :limit => 12, :null => false
      t.column :present,    :boolean, :default => false, :null => false
      t.column :count,      :integer
    end
    
    create_table :survey_volunteers  do |t|
      t.column :survey_id,    :integer, :null => false
      t.column :volunteer_id, :integer, :null => false
			t.column :travel_time,	:integer
      # survey role re-added per need for submitter / data collector separation
      t.column :role,       :string, :limit => 20
    end
  end

  def self.down
    drop_table :survey_tracks
    drop_table :survey_volunteers
  end
end