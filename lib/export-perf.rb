# anaylze the runtime of various windows of exporting
ActiveRecord::Base.establish_connection

time_spans = [
  ['01-01-2008', '01-01-2008'], #  1 day
  ['01-01-2008', '01-10-2008'], # 10 days
  ['01-01-2008', '01-31-2008'], # 30 days
]

time_spans.each do |span|
  (start_date, end_date) = span

  survey_query = "
    EXPLAIN SELECT 
    EXTRACT(day FROM s.survey_date) AS survey_day,
    EXTRACT(month FROM s.survey_date) AS survey_day,
    EXTRACT(year FROM s.survey_date) AS survey_day,
    s.survey_date,
    s.id   AS survey_id,
    s.code AS survey_code,
    b.id   AS bird_code,
    r.name AS region,
    be.name as beach_name,
    be.length as beach_length,
    to_char(s.start_time, 'HH24:MI') AS survey_start_time,
    to_char(s.end_time, 'HH24:MI') AS survey_end_time,
    s.duration,
    s.weather,
    s.oil_present,
    s.oil_frequency,
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
    s.verified,
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
    WHERE s.survey_date >= '#{start_date}' AND
          s.survey_date <= '#{end_date}'
    ORDER BY s.survey_date;
  "

  query = "EXPLAIN SELECT * FROM surveys s
    LEFT JOIN birds b ON s.id = b.survey_id 
    LEFT JOIN plumages pl ON pl.id = b.plumage_id
    LEFT JOIN ages a ON a.id = b.age_id
    LEFT JOIN species sp ON sp.id = b.species_id 
    LEFT JOIN groups g ON g.id = b.group_id 
    LEFT JOIN subgroups sg ON sg.id = b.subgroup_id 
    LEFT JOIN beaches be ON s.beach_id = be.id 
    LEFT JOIN regions r ON be.region_id = r.id 
    WHERE s.survey_date >= '#{start_date}' AND
          s.survey_date <= '#{end_date}'
    ORDER BY s.survey_date;"
   
  puts "#{start_date}--#{end_date}"
  puts query
  #rs = ActiveRecord::Base.connection.execute(survey_query)
  #puts rs[0]
  exit
end
