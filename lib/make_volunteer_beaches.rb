# find all surveys, make their volunteer <-> beach mappings.


all_beaches = Beach.find(:all)
all_beaches.each { |b|
	puts "At beach #{b.id}"
  surveys = b.surveys

	totals = {}	
	surveys.each { |s|
		sv = s.volunteers
		sv.each { |v|
			totals[v.id] ||= 0
			totals[v.id] += 1
		}
	}
	totals.each { |volunteer_id, count|
		vb = VolunteerBeach.new(:beach_id => b.id, :frequency => count,
					 :volunteer_id => volunteer_id)
		vb.save!
 	}
}
