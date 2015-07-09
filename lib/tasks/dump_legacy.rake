desc 'Create YAML migration data from a copy of the legacy database.
Set the connection parameters in database.yml as db `legacy`.'

task :dump_legacy => :environment do
  config = YAML::load_file("#{RAILS_ROOT}/config/database.yml")['legacy']
  ActiveRecord::Base.establish_connection(config)
  
  # skip over the 'content' related tables -- these need to be refactored
  skip_tables = ["breakingnewscontent", "content", "page", "tabpage", "trainingcontent"] 

  (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name| 
    i = "000" 
    filename = "#{RAILS_ROOT}/db/migrate/data/#{table_name}.sql"
    File.open(filename, 'w' ) do |file|
      puts "writing #{filename}..."
      # dump only the data itself, in INSERT form
      system "pg_dump -U #{config['username']} --no-owner -F p " \
             "-a -d -f #{filename} -C -t #{table_name} #{config['database']}"
    end
  end
end