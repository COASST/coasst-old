# find all Volunteers, and create their friend records.

all_volunteers = Volunteer.find(:all)
all_volunteers.each { |v|

  f = {}

  # every volunteer gets the guest user in their list
  f[370] = 1

  vs = v.surveys
  vs.each { |s|
    s.survey_volunteers.each { |friend|
			if friend.role == 'data collector'
				f[friend.volunteer_id] ||= 0
				f[friend.volunteer_id] += 1
			end
    }
  }

  # insert friends into volunteer_friends mapping
  f.each { |friend_id, count|
    vf = VolunteerFriend.new(:volunteer_id => v.id, :frequency => count, 
           :friend_id => friend_id)
    vf.save!
  }
}

