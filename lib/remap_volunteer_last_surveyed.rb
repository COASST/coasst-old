# remap volunteer involvement categories to match set columns

sql = "SELECT DISTINCT(volunteer_id), MAX(survey_date) AS survey_date FROM (SELECT sv.volunteer_id, s.survey_date FROM survey_volunteers AS sv LEFT JOIN surveys AS s ON s.id = sv.survey_id) AS svd GROUP BY svd.volunteer_id;"

ActiveRecord::Base.establish_connection
rs = ActiveRecord::Base.connection.execute(sql)


# for each item, update the last surveyed time
rs.each do |r|
  id = r['volunteer_id'].to_i
  survey_date = r['survey_date']

  vl_sql = "UPDATE volunteers SET last_surveyed_date = '#{survey_date}' WHERE id = #{id}"
  vl_rs = ActiveRecord::Base.connection.execute(vl_sql)
end
