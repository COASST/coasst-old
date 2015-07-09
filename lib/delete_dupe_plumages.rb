class DeleteDupePlumages < ActiveRecord::Migration


all_species = Species.find(:all)
all_plumages = Plumage.find(:all)

all_species.each { |s|
	puts "At species #{s.id}"
  
	dupes = []
	# find duplicate plumages
	vol = s.plumages.select { |sp| sp.admin_only == false}
	s.plumages.select { |admin| admin.admin_only == true}.each { |p|
		vol.each { |sp|
		  if sp.name == p.name
				dupes << p
			end
		}
	}
	
	dupes.each { |d|
		execute("DELETE FROM species_plumages WHERE id = #{d.id}")
	}
}

end
