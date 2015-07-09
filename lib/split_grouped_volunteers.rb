# find all 'merged' users (couples who used a single account) and split them up.

grouped_volunteers = {21 => [31, 1577]}


grouped_volunteers.each do |source_v, dest_v|
  
  # copy the account information to the new primary account
  v = Volunteer.find(source_v)
  dv = Volunteer.find(dest_v.first)
  dv.update_attributes({:has_account => v.has_account,
                        :hashed_password => v.hashed_password,
                        :salt => v.salt})
  dv.save!

  # add the new volunteers as data collectors for each of the surveys found
  survey_volunteers = SurveyVolunteer.find(:all, :conditions => {
                        :volunteer_id => source_v})
  puts "survey volunteers found: #{survey_volunteers.length}"
  survey_volunteers.each do |sv|
    valid_count = 0
    dest_v.each do |new_volunteer|
      sv_new = SurveyVolunteer.new(:volunteer_id => new_volunteer, 
                  :survey_id => sv.survey_id, :role => 'data collector')
      if sv_new.save!
        valid_count += 1
      end 
      puts "new: #{new_volunteer}, survey: #{sv.survey_id}"
    end

    # if we successfully added the two new children entries, delete the original
    if valid_count == 2
      sv.destroy
    end
  end
end

