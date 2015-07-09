# remap identificiation levels based on Jane's designation

sql = "SELECT id, identification_level FROM birds WHERE identification_level IS NOT NULL"

ActiveRecord::Base.establish_connection
rs = ActiveRecord::Base.connection.execute(sql)

rs.each do |r|
  id = r['id'].to_i
  level = r['identification_level']

  if level == 'None'
    next
  end
  # default values for when any level is set
  identification_level_family = "'Correct'"
  identification_level_group = 'NULL'
  identification_level_species = 'NULL'

  if level == 'Subgroup':
    identification_level_group = "'Correct'"
  elsif level == 'Species'
    identification_level_group = "'Correct'"
    identification_level_species = "'Correct'"
  end
  bird_sql = "UPDATE birds SET (identification_level_family, identification_level_group, identification_level_species) = (#{identification_level_family}, #{identification_level_group}, #{identification_level_species}) WHERE id = #{id}"
  bird_rs = ActiveRecord::Base.connection.execute(bird_sql)
end
