require 'fastercsv'

# ruby lacks deep copying, use marshal to create true duplicates
class Object
  def m_dup
    Marshal.load(Marshal.dump(self))
  end
end

survey_query = "
  SELECT 
  EXTRACT(day FROM s.survey_date) AS survey_day,
  EXTRACT(month FROM s.survey_date) AS survey_day,
  EXTRACT(year FROM s.survey_date) AS survey_day,
  s.survey_date,
  s.id   AS survey_id,
  s.code AS survey_code,
  b.id   AS bird_id,
  b.code AS bird_code,
  r.name AS region,
  be.name as beach_name,
  be.length as beach_length,
  to_char(s.start_time, 'HH24:MI') AS survey_start_time,
  to_char(s.end_time, 'HH24:MI') AS survey_end_time,
  s.duration,
  s.weather,
  s.oil_present,
  s.oil_sheen,
  s.oil_tarballs,
  s.oil_goopy,
  s.oil_mousse,
  s.oil_comment AS survey_oil_comment,
  s.wood_present,
  s.wood_size,
  s.wood_continuity,
  s.wood_zone,
  s.wrack_present,
  s.wrack_width,
  s.wrack_continuity, 
  be.substrate,
  be.orientation,
  s.comments AS survey_comments,
  b.verified AS bird_verified,
  b.refound AS bird_refound,
  b.where_found as bird_where_found,
  b.foot_condition,
  b.eyes,
  b.intact,
  b.head AS head_present,
  b.breast AS breast_present,
  b.feet,
  b.wings,
  b.entangled,
  b.entangled_comment,
  b.oil,
  b.oil_comment,
  b.sex,
  b.collected,
  b.collected_comment,
  b.photo_count,
  b.tie_location,
  b.tie_location_comment,
  b.tie_number,
  b.is_bird,
  b.comment,
  b.verified,
  b.verification_comment,
  b.identification_level,
  b.tie_other,
  sp.name AS species_name,
  g.name AS group_name,
  sg.name AS subgroup_name,
  a.name AS age,
  pl.name AS plumage,
  b.bill_length,
  b.wing_length,
  b.tarsus_length
  FROM surveys s 
  LEFT JOIN birds b ON s.id = b.survey_id 
  LEFT JOIN plumages pl ON pl.id = b.plumage_id
  LEFT JOIN ages a ON a.id = b.age_id
  LEFT JOIN species sp ON sp.id = b.species_id 
  LEFT JOIN groups g ON g.id = b.group_id 
  LEFT JOIN subgroups sg ON sg.id = b.subgroup_id 
  LEFT JOIN beaches be ON s.beach_id = be.id 
  LEFT JOIN regions r ON be.region_id = r.id 
  WHERE s.survey_date >= '1-1-2007' and s.survey_date <= '1-1-2007';
"

@surveys = Survey.find_by_sql(survey_query)
@ids = @surveys.map {|s| s.survey_id}
print "found ", @ids.count, " results."
# if we have less than 10k results, return only those listed.
# with more than ~10k, the parsing the string outweighs the benefit
if @ids.count < 10000
  condition = "survey_id in (#{@ids.join(",")})"
  @tracks = SurveyTrack.find(:all, :conditions => condition)
  @survey_volunteers = SurveyVolunteer.find(:all, :conditions => condition)
else
  @tracks = SurveyTrack.find(:all)
  @survey_volunteers = SurveyVolunteer.find(:all)
end
@volunteers = {}
Volunteer.find(:all).map {|v| @volunteers[v.id] = v.fullname} # 300ms

# get column names, prettify them
columns = @surveys.first.attributes.keys.map {|c| c.titleize}

@tl = {}
# this is inelegant, but that's why you don't program at 2am while sick
classes = SurveyTrack::TrackClass.map {|a| a[1]}
counts = classes.map {|c| "#{c}_count"}.flatten
present = classes.map {|c| "#{c}_present"}.flatten
track_types = {}
counts.each {|c| track_types[c] = 0}
present.each {|c| track_types[c] = false}

@tracks.each do |track|
  if not @tl.has_key?(track.survey_id)
    @tl[track.survey_id] = track_types.m_dup
  end
  @tl[track.survey_id]["#{track.track_type}_present"] = track.present
  @tl[track.survey_id]["#{track.track_type}_count"] = track.count
end

# only care about two roles for the report
roles = {'submitter' => [], 'data collector' => []}
@vl = {}
@survey_volunteers.each do |sv|
  if not @vl.has_key?(sv.survey_id)
    @vl[sv.survey_id] = roles.m_dup
  end
  if roles.has_key?(sv.role)
    @vl[sv.survey_id][sv.role] << @volunteers[sv.volunteer_id]
  end
end

@vl.each do |k, v|
  v.each do |i, j|
    @vl[k][i] = j.join(',')
  end
end
#puts @vl.to_yaml
first_id = @ids.first.to_i
#puts @tl[first_id].to_yaml
#puts @tl[first_id].values.to_yaml

# get column names, prettify them
column_keys = @surveys.first.attributes.keys + @tl[first_id].keys + roles[first_id].keys
columns = column_keys.map {|c| c.titleize}
#puts @surveys.first.to_yaml

output = FasterCSV.generate do |csv|
  # Output header to CSV
  csv << columns
  
  @surveys.each do |survey|
    id = survey.survey_id.to_i
             
    # add all survey data queried
    values = survey.attributes.values
    if @tl.has_key?(id)
      values = values + @tl[id].values
    end
    if @vl.has_key?(id)
      values = values + @vl[id].values
    end
    csv << values
  end
end

File.open('test-output.csv', 'w+') {|f| f.write(output)}
