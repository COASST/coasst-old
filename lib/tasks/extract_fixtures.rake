desc 'Create YAML test fixtures from data in an existing database.  
Defaults to development database.  Set RAILS_ENV to override.'

# uses induktiv's BigDecimal workaround from
# http://blog.induktiv.at/archives/6-YAML-and-BigDecimal-a-temporary-solution.html
namespace :db do
namespace :fixtures do
  task :extract => :environment do
    sql  = "SELECT * FROM %s"
    skip_tables = ["breakingnewscontent", "content", "page", "tabpage", "trainingcontent", "schema_info", "sessions"]
    ActiveRecord::Base.establish_connection
    (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
      i = "000"
      File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end
end
end