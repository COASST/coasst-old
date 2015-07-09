class MakeAdminAges < ActiveRecord::Migration

# give admin-only access to all ages not available for each species

all_species = Species.find(:all)
all_ages = Age.find(:all)

all_species.each { |s|
	puts "At species #{s.id}"

	existing = s.ages.collect { |sa| sa.name}
	admin_ages = all_ages.select { |all|
		!existing.include? all.name
	}

	remove = []
	if existing.include? 'immature'
		remove = admin_ages.select { |ae| ['juvenile', 'subadult'].include? ae.name }
	elsif existing.include? 'juvenile' or existing.length == 1
		remove = admin_ages.select { |ae| ae.name == 'immature' }
	end
	
	remove.each { |r|
			admin_ages.delete(r)
	}
	
	admin_ages.each { |valid|
			execute("INSERT INTO species_ages (species_id, age_id, admin_only)
				       VALUES (#{s.id}, #{valid.id}, true)")
	}
}

end
