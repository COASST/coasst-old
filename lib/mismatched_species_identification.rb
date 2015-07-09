#!../script/runner
# find birds which have information which differs from their species data.

sql = "SELECT b.id, s.name, b.species_id,
   b.group_id, s.group_id as spp_group_id,
   b.subgroup_id, s.subgroup_id AS spp_subgroup_id,
   ge.name as group_name, g.name as spp_group_name,
   sge.name as subgroup_name, sg.name as spp_subgroup_name
 FROM birds b 
 LEFT JOIN species s on s.id = b.species_id
 LEFT JOIN groups g on g.id = s.group_id
 LEFT JOIN groups ge on ge.id = b.group_id
 LEFT JOIN subgroups sg on sg.id = s.subgroup_id
 LEFT JOIN subgroups sge on sge.id = b.subgroup_id
 WHERE species_id != 114 AND b.group_id != 35 AND b.subgroup_id != 46 AND
   (b.group_id != s.group_id OR b.subgroup_id != s.subgroup_id)
 ORDER BY name"

ActiveRecord::Base.establish_connection
rs = ActiveRecord::Base.connection.execute(sql)

rs.each do |r|
  id = r['id'].to_i

  #if !r['group_id'].nil?
    #if r['spp_group_id'] != r['group_id']
      #puts "mismatch: #{r['group_id']} to #{r['spp_group_id']} on spp #{r['species_id']}"
    #end 
  #end
end

#\copy (SELECT b.id, s.name, ge.name as group_name, g.name as spp_group_name, sge.name as subgroup_name, sg.name as spp_subgroup_name FROM birds b LEFT JOIN species s on s.id = b.species_id LEFT JOIN groups g on g.id = s.group_id LEFT JOIN groups ge on ge.id = b.group_id LEFT JOIN subgroups sg on sg.id = s.subgroup_id LEFT JOIN subgroups sge on sge.id = b.subgroup_id WHERE species_id != 114 AND b.group_id != 35 AND b.subgroup_id != 46 AND (b.group_id != s.group_id OR b.subgroup_id != s.subgroup_id) ORDER BY name) to '/tmp/test.csv' with CSV
