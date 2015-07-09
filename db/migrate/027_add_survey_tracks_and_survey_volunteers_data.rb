class AddSurveyTracksAndSurveyVolunteersData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "survey_volunteers"
    load_data "survey_tracks"
    execute("UPDATE surveys SET duration = (EXTRACT(hours FROM end_time - start_time) * 60 + " + \
                "EXTRACT(minutes FROM end_time - start_time)) WHERE id > 0") 
  end

  def self.down
     execute("DELETE FROM survey_volunteers WHERE survey_id <= 12519")
     execute("DELETE FROM survey_tracks WHERE survey_id <= 12519")
  end
end
