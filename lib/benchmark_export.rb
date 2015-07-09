require 'benchmark'

n = 50

Benchmark.bm do |x|

    one_month_sql = "SELECT * FROM surveys s LEFT JOIN birds b ON s.id = b.survey_id LEFT JOIN plumages pl ON pl.id = b.plumage_id LEFT JOIN ages a ON a.id = b.age_id LEFT JOIN species sp ON sp.id = b.species_id LEFT JOIN groups g ON g.id = b.group_id LEFT JOIN subgroups sg ON sg.id = b.subgroup_id LEFT JOIN beaches be ON s.beach_id = be.id LEFT JOIN regions r ON be.region_id = r.id WHERE s.survey_date >= '01-01-2008' AND s.survey_date <= '01-31-2008' ORDER BY s.survey_date;"

    x.report("execute one month of data query") { n.times {rs = ActiveRecord::Base.connection.execute(one_month_sql)}}

    one_month_materialized_sql = "SELECT * FROM export_surveys_unmaterialized s WHERE s.survey_date >= '01-01-2008' AND s.survey_date <= '01-31-2008' ORDER BY s.survey_date;"

    x.report("execute one month of data query, materialized") { n.times {rs = ActiveRecord::Base.connection.execute(one_month_materialized_sql)}}

end
