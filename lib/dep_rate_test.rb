# test our deposition rate calculations on a known result

# coasst years are from June to May, so:
# 2007-2008 should get data from June 2007 to May 2008.
def coasst_year(start_year, end_year)
	start_date = "#{start_year}-06-01"
	end_date= "#{end_year}-05-31"
	return [start_date, end_date]
end 

beach_id = 50

(start_date, end_date) = coasst_year(2007, 2008)
#  sql = "
#  SELECT tie_number, COUNT(tie_number), refound FROM (
#          SELECT b.id AS bird_id,
#                 s.id AS survey_id,
#                 b.refound AS refound,
#                 b.tie_number,
#                 EXTRACT(day FROM s.survey_date) AS survey_day,
#                 EXTRACT(month FROM s.survey_date) AS survey_month,
#                 EXTRACT(year FROM s.survey_date) as survey_year
#          FROM birds b LEFT JOIN surveys s ON b.survey_id = s.id
#          WHERE s.verified IS TRUE AND s.beach_id = #{beach_id}) AS depi_surveys
#  WHERE survey_year = #{year} AND survey_month = #{month} GROUP BY tie_number, refound;
#  "

# this initial query gets us all the deposition data for a particular beach
# fairly expensive (200ms)
sql = "
SELECT b.tie_number, b.refound, count(tie_number) as tie_count, b.survey_id, s.beach_id,
      to_char(survey_date, 'YYYY-MM') AS year_month
  FROM birds b LEFT JOIN surveys s ON b.survey_id = s.id
  WHERE s.verified AND s.beach_id IN (#{beach_id})
  GROUP BY tie_number, refound, b.survey_id, year_month, s.beach_id
  ORDER BY s.beach_id, year_month;
"
# AND
#          s.survey_date >= '#{start_date}' AND
#          s.survey_date <= '#{end_date}'


ActiveRecord::Base.establish_connection
rs = ActiveRecord::Base.connection.execute(sql)


# XXX fixes needed below
# find the total survey count for that time... very fast
survey_sql = "
SELECT COUNT(*), year_month FROM (
       SELECT DISTINCT(b.survey_id),
              to_char(survey_date, 'YYYY-MM') AS year_month
       FROM birds b
       LEFT JOIN surveys s ON b.survey_id = s.id
       WHERE s.verified IS TRUE AND
             s.beach_id = #{beach_id}) AS depi_surveys
GROUP BY year_month
ORDER BY year_month
"
# only want distinct survey-year pairs
# SELECT DISTINCT(b.survey_id),
#        to_char(survey_date, 'YYYY-MM') AS year_month
# FROM birds b
# LEFT JOIN surveys s ON b.survey_id = s.id
# WHERE s.verified IS TRUE AND
#       s.beach_id = 50 ORDER BY year_month;


#survey_count = ActiveRecord::Base.connection.execute(survey_sql)[0]['count'].to_i
countset = ActiveRecord::Base.connection.execute(survey_sql)

counts = {}
new_finds = {}
refinds = {}
refinds_in_month = {}
dep_data = {}

countset.each do |r|
  ym = r['year_month']
  dep_data[ym] = { 'count'    => r['count'].to_i,
                   'new_finds' => [],
                   'refinds'   => [],
                   'refinds_in_month' => [],
  }
end

rs.each do |r|
  ym = r['year_month']
  if r['refound'] == 'f'
    dep_data[ym]['new_finds'].push(r['tie_number'])
  else
    dep_data[ym]['refinds'].push(r['tie_number'])
  end
end


dep_data.each do |ym, d|
  d['refinds'].each do |rf|
    rf.each do |r|
      if dep_data[ym]['new_finds'].include?(r)
        dep_data[ym]['refinds_in_month'].push(r)
      end
    end
  end
end

beach = Beach.find(beach_id)

# calculate deposition rate as the following:
#
#  all new finds + first refinds in the same month
#  -----------------------------------------------
#               # surveys * beach length km

puts "ym:\tnew:\trefinds:\tsurvey count:\tdeposition rate\n"
dep_data.to_a.sort_by {|key, value| key}.each do |ym, d|
  deposition_rate = (d['new_finds'].length + d['refinds_in_month'].length) / (d['count'] * beach.length)
  puts "#{ym}\t\t#{d['new_finds'].length}\t#{d['refinds'].length}\t#{d['count']}\t%.5f\n" % deposition_rate
end
exit
puts "new: #{new_finds.length}\nrefinds: #{refinds_in_month.length}"

