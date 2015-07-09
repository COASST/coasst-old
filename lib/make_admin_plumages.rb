class MakeAdminPlumages < ActiveRecord::Migration

# give admin-only access to all plumages not available for each species

all_species = Species.find(:all)
all_plumages = Plumage.find(:all)
all_species.each { |s|
	puts "At species #{s.id}"
  
	admin_plumages = all_plumages - s.plumages
	
	admin_plumages.each { |plumage|
		sp = execute(
		"INSERT INTO species_plumages (species_id, plumage_id, admin_only) VALUES " +
		"(#{s.id}, #{plumage.id}, true)")
	}
}

end
