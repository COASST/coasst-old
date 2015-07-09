namespace :db do
  desc "Prints the migration version"
  task :schema_version => :environment do
    ver = ActiveRecord::Base.connection.select_value('SELECT version FROM schema_info')
    puts "Database schema currently at version #{ver}"
  end
end