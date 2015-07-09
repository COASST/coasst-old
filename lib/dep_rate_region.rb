#!/home/scw/coasst/da/script/runner -e production
# to calculate a region-level deposition rate, you're actually computing the deposition rate at
# _each_ individual beach, then sumarizing those beaches.


# coasst years are from June to May, so:
# 2007-2008 should get data from June 2007 to May 2008.
def coasst_year(start_year, end_year)
	start_date = "#{start_year}-06-01"
	end_date= "#{end_year}-05-31"
	return [start_date, end_date]
end 


region_id = 1

(start_date, end_date) = coasst_year(2007, 2008)

region_beaches_sql = "SELECT id FROM beaches WHERE region_id = #{region_id}"
# this initial query gets us all the deposition data for a particular beach
# fairly expensive (200ms)
sql = "
SELECT b.tie_number, b.refound, count(tie_number) as tie_count, b.survey_id, s.beach_id,
       to_char(survey_date, 'YYYY-MM') AS year_month
  FROM birds b LEFT JOIN surveys s ON b.survey_id = s.id
  WHERE s.verified AND 
        s.beach_id = ANY(ARRAY(#{region_beaches_sql})) AND
        s.survey_date >= '#{start_date}' AND
        s.survey_date <= '#{end_date}'
  GROUP BY tie_number, refound, b.survey_id, year_month, s.beach_id
  ORDER BY s.beach_id, year_month;
"

b_sql = "
SELECT COUNT(DISTINCT(beach_id)) AS beach_count,
      to_char(survey_date, 'YYYY-MM') AS year_month
  FROM surveys s
  WHERE s.verified AND 
        s.beach_id = ANY(ARRAY(#{region_beaches_sql})) AND
        s.survey_date >= '#{start_date}' AND
        s.survey_date <= '#{end_date}'
  GROUP BY year_month 
  ORDER BY year_month
"

beach_sql = "SELECT id, length
             FROM beaches
             WHERE id = ANY(ARRAY(#{region_beaches_sql}))"

beach_results = ActiveRecord::Base::connection.execute(beach_sql)

bs = ActiveRecord::Base.connection.execute(b_sql)

rs = ActiveRecord::Base.connection.execute(sql)

# find the total survey count for that time... very fast
survey_sql = "
SELECT COUNT(*), beach_id, year_month FROM (
       SELECT id, beach_id, to_char(survey_date, 'YYYY-MM') AS year_month
       FROM surveys
       WHERE verified IS TRUE AND
             beach_id = ANY(ARRAY(#{region_beaches_sql}))) AS depi_surveys
GROUP BY year_month, beach_id
ORDER BY year_month;"

#WHERE survey_date >= #{start_date} AND survey_date <= #{end_date}

countset = ActiveRecord::Base.connection.execute(survey_sql)

dep_data = {}
lengths = {}

countset.each do |r|
  bid = r['beach_id']
  ym = r['year_month']
  if dep_data[ym].nil?
    dep_data[ym] = {}
  end
  dep_data[ym][bid] = { 'count'     => r['count'].to_i,
                        'new_finds' => [],
                        'refinds'   => [],
                        'refinds_in_month' => [],
  }
end

beach_results.each do |r|
  bid = r['id']
  lengths[bid] = r['length'].to_f
end

rs.each do |r|
  ym = r['year_month']
  bid = r['beach_id']
  if r['refound'] == 'f'
    dep_data[ym][bid]['new_finds'].push(r['tie_number'])
  else
    dep_data[ym][bid]['refinds'].push(r['tie_number'])
  end
end

dep_data.each do |ym, records|
  records.each do |bid, d|
    d['refinds'].each do |rf|
      rf.each do |r|
        if dep_data[ym][bid]['new_finds'].include?(r)
          dep_data[ym][bid]['refinds_in_month'].push(r)
        end
      end
    end
  end
end

# calculate deposition rate as the following:
#
#  all new finds + first refinds in the same month
#  -----------------------------------------------
#               # surveys * beach length km

dep_data.each do |ym, records|
  records.each do |bid, d|
    dep_data[ym][bid]['deposition_rate'] = (d['new_finds'].length + d['refinds_in_month'].length) / (d['count'] * lengths[bid])
  end
end

def variance(population)
  n = 0
  mean = 0.0
  s = 0.0
  population.each { |x|
    n = n + 1
    delta = x - mean
    mean = mean + (delta / n)
    s = s + delta * (x - mean)
  }
  # if you want to calculate std deviation
  # of a sample change this to "s / (n-1)"
  return s / n
end

# calculate the standard deviation of a population
# accepts: an array, the population
# returns: the standard deviation
def standard_deviation(population)
  Math.sqrt(variance(population))
end

def standard_error(population)
  standard_deviation(population) / Math.sqrt(population.length)
end

def average(population)
  population.sum / population.length
end

time = '2008-01'
puts time
puts '-------'
 
dep_data[time].each do |bid, d|
  puts "#{bid}\t\t#{d['new_finds'].length}\t#{d['refinds'].length}\t#{d['count']}\t%.5f\n" % d['deposition_rate']
end

rates = dep_data[time].collect {|b, d| d['deposition_rate']}
# NOTE: these numbers don't equal those given in the SAS output, because many beaches
# have had their lengths modified, which changes the deposition rate, and these statistics.
puts "population (n): #{rates.length}"
puts "standard deviation: #{standard_deviation(rates)}"
puts "deposition rate: #{average(rates)}"
puts "standard error: #{standard_error(rates)}"
# now, let's compute a few other metrics -- standard deviation, standard error
