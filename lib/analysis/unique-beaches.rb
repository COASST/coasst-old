#!/usr/bin/env ruby
#i want to know who has done surveys on the greatest number of unique beaches.
#
#ie: someone surveyed 10 different beaches over the COASST year
#
#coasst year is june 1, 2008-may 31, 2009
#
#the person cannot be:
#guest
#amnwr staff
#mary sue brancato
#janet lamont
#john barimo
#penelope chilton
#jane dolliver
#field trip
#eco office staff

require 'fastercsv'

ActiveRecord::Base.establish_connection

negate_sql = "
select id from volunteers where lower(fullname) IN ('* guest', 'amnwr seasonal staff', 'coasst staff', 'mary sue brancato', 'janet lamont', 'john barimo', 'penelope chilton', 'jane dolliver', 'field trip', '* st paul eco office staff');
"

negate = ActiveRecord::Base.connection.execute(negate_sql)

negate_ids = []

negate.each do |n|
  negate_ids.push(n.to_s)
end

sql = "
  select sv.volunteer_id, s.beach_id 
  FROM surveys s 
  LEFT JOIN survey_volunteers sv on s.id = sv.survey_id 
  WHERE s.survey_date >= '06-01-2008' AND
        s.survey_date >= '05-31-2009'
  GROUP BY sv.volunteer_id, beach_id
"

rs = ActiveRecord::Base.connection.execute(sql)

volunteer_beaches = {}
rs.each do |r|
  (volunteer, beach) = r
  if not negate_ids.include? volunteer
    if volunteer_beaches.has_key? volunteer
      if not volunteer_beaches[volunteer].include? beach
        volunteer_beaches[volunteer].push(beach)
      end
    else
      volunteer_beaches[volunteer] = [beach]
    end
  end
end

names = {}
names_sql = "select id, fullname from volunteers"
ns = ActiveRecord::Base.connection.execute(names_sql)
ns.each do |n|
  (id, name) = n
  names[id] = name
end

output = FasterCSV.generate do |csv|
  # Output header to CSV
  csv << ['Volunteer Name', 'Volunteer ID', 'Beach Count']

  volunteer_beaches.each do |v, b|
    csv << [names[v], v, b.length]
  end
end 

File.open('volunteer-beach-popularity-contest.csv', 'w+') {|f| f.write(output)}
