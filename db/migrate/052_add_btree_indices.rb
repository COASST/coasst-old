class AddBtreeIndices < ActiveRecord::Migration
  def self.up
    execute("CREATE INDEX birds_refound_species_idx ON birds(refound, species_id);")
    execute("CREATE INDEX birds_species_group_idx ON birds(species_id, group_id);")
    execute("CREATE INDEX birds_oil_refound_verified_idx ON birds(oil, refound, verified);")
    execute("CREATE INDEX survey_beach_project_idx ON surveys(beach_id, project);")
    execute("CREATE INDEX survey_beach_verified_idx ON surveys(beach_id, verified);")
    execute("CREATE INDEX survey_volunteers_volunteer_id_idx ON survey_volunteers(volunteer_id);")
  end

  def self.down
    execute("DROP INDEX birds_refound_species_idx;")
    execute("DROP INDEX birds_species_group_idx;")
    execute("DROP INDEX birds_oil_refound_verified_idx;")
    execute("DROP INDEX survey_beach_project_idx;")
    execute("DROP INDEX survey_beach_verified_idx;")
    execute("DROP INDEX survey_volunteers_volunteer_id_idx;")
  end
end
