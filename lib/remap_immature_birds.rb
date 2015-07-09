puts "Find all species"
spp = Species.find(:all, :include => :ages)
immature = Age.find(5)
immature_spp = []

puts "Find immature species"
spp.each do |s|
  if s.ages.include?(immature)
    immature_spp << s.id
  end
end

# find all birds with immature set
puts "find all birds"
birds = Bird.find(:all)
birds.each do |b|
  if immature_spp.include?(b.species_id)
    if b.age_id == 2 or b.age_id == 3
      puts "modifying age for bird ##{b.id}"
      b.age_id = 5
      b.save(false) # skip validation as old data doesn't have photo counts, etc
    end
  end
end
