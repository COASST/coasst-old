module DataLoader

  def load_data(name = 'data', ext = 'sql')
    file_name = data_file(name, ext) || fail("Cannot find the data file for #{ name }")
    execute_sql_from_file(file_name)
		reset_sequence(name)
  end

  def execute_sql_from_file(file_name)
    say_with_time("Executing SQL from #{ file_name }") do
      IO.readlines(file_name).join.gsub("\r\n", "\n").split(";\n").each do |s|
        execute(s) unless s == "\n"
      end
    end
  end

	def reset_sequence(table)
		begin
			execute("SELECT setval('#{table.to_s}_id_seq', (SELECT MAX(id) FROM #{table.to_s}), true)")
		rescue ActiveRecord::StatementInvalid
			# join tables don't contain raw id values
		end
	end

private
    
  def data_file(name, ext)
    mode = ENV['RAILS_ENV'] || 'development'
    [ 
      data_file_name(mode + '_', name, ext),
      data_file_name('', name, ext)
    ].detect { |file_name| File.exists?(file_name) }
  end 

  def data_file_name(prefix, name, ext)
    "#{ RAILS_ROOT }/db/migrate/data/#{ prefix }#{ name }.#{ ext }"
  end
  
end
