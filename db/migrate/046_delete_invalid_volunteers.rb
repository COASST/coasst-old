class DeleteInvalidVolunteers < ActiveRecord::Migration
  def self.up
    selection_sql = "SELECT id FROM volunteers WHERE first_name IN('(SELECT)', 'Faky', 'Fay')"
    execute("DELETE FROM volunteer_friends WHERE volunteer_id IN (#{selection_sql}) OR friend_id IN (#{selection_sql})");
    execute("DELETE FROM volunteer_beaches WHERE volunteer_id IN (#{selection_sql})");
    execute("DELETE FROM survey_volunteers WHERE volunteer_id IN (#{selection_sql})");
    execute("DELETE FROM roles_volunteers WHERE volunteer_id IN (#{selection_sql})");
    execute("DELETE FROM volunteers WHERE id IN (#{selection_sql})")
  end

  def self.down
  end
end
