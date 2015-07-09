# find all duplicate accounts (users who have made more than one account) and merge them.

duplicate_volunteers = {
  # src           # dest
  [1349] =>       1097,
  [1496] =>       117,
  [1637, 1458] => 1394,
  [1330] =>       742,
  [1491] =>       1366,
  [1310] =>       1110,
  [1483] =>       1277,
  [1359] =>         92,
  [1477] =>       1242,
  [1492, 1538] => 1389,
  [1353] =>       1331,
  [1564] =>       1431,
  [1651] =>        978,
  [1357] =>       1180,
  [1326] =>        100,
  [1401] =>        973,
  [1629] =>       1007,
  [1571] =>        761,
  [1348] =>        685,
  [1525] =>       1250,
  [1367] =>        588,
  [1531] =>       1475,
  [1371] =>        592,
  [1368] =>        609,

}


duplicate_volunteers.each do |source_v, dest_v|
  
  # copy the account information to the new primary account
  sv = Volunteer.find(:all, :conditions => {:id => source_v})
  dv = Volunteer.find(dest_v)

  # XXX copy over _all_ fields from the old data, go through the attributes and mass-copy
  # everything other than the id? what else?

  # CHECK UPDATED ON

  # add the new volunteers as data collectors for each of the surveys found
  survey_volunteers = SurveyVolunteer.find(:all, :conditions => {
                        :volunteer_id => source_v})
  puts "survey volunteers found: #{survey_volunteers.length}"

  # remap the friends
  volunteer_friends = VolunteerFriend.find(:all, :conditions => {
                        :volunteer_id => source_v})

  puts "volunteer friends found: #{volunteer_friends.length}"
#  survey_volunteers.each do |sv|
#    valid_count = 0
#    dest_v.each do |new_volunteer|
#      sv_new = SurveyVolunteer.new(:volunteer_id => new_volunteer, 
#                  :survey_id => sv.survey_id, :role => 'data collector')
#      if sv_new.save!
#        valid_count += 1
#      end 
#      puts "new: #{new_volunteer}, survey: #{sv.survey_id}"
#    end
#
#    # if we successfully added the two new children entries, delete the original
#    if valid_count == 2
#      sv.destroy
#    end
#  end
end

