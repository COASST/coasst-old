require 'fastercsv'

columns = ['Volunteer', 'Volunteer ID', 'Surveys', 'Survey Minutes', 'Birds', 'Finds', 'Families', 'Species', 'Id Spp: Correct', 'Id Spp: Correct Unknown', 'Id Spp: Ambitious', 'Id Spp: Timid', 'Id Spp: Incorrect', 'Id Spp: Accuracy Unknown']

output = FasterCSV.generate do |csv|
  # Output header to CSV
  csv << columns

  #v = Volunteer.find(:all, :conditions => {:id => 112})
  v = Volunteer.find(:all)

  values = []
  v.each do |v|
    survey_ids = SurveyVolunteer.find(:all, :conditions => {:volunteer_id => v.id, :role => 'data collector'}).map {|sv| sv.survey_id}

    # all volunteer surveys
    surveys = Survey.find(:all, :conditions => {:id => survey_ids, :survey_date => '2008-6-1'..'2012-5-14'})

    values = []
    values << v.fullname
    values << v.id
    values << surveys.length # survey count
    values << surveys.sum {|s| s.duration} # survey time

    bird_count = 0
    bird_finds = 0
    spp = []
    family = []

    id_level_spp = {}
    Bird::VerificationLevel.map {|vl| id_level_spp[vl] = 0}

    surveys.each do |s|
      if !s.birds.empty?
        s.birds.each do |b|
          if b.is_bird and b.verified
            bird_count += 1
            if !b.refound?
              bird_finds += 1
              spp_id = b.species_id
              family_id = b.foot_type_family_id
              if !spp_id.nil? and !spp.include? spp_id
                spp << spp_id
              end
              if !family_id.nil? and !family.include? family_id
                family << family_id
              end
              if !b.identification_level_species.nil?
                id_level_spp[b.identification_level_species] += 1
              end
            end
          end
        end
      end
    end

    values << bird_count
    values << bird_finds
    values << family.length
    values << spp.length
    Bird::VerificationLevel.each {|vl| values << id_level_spp[vl]}
    csv << values
  end
end

File.open('volunteer-accuracy-by-bird.csv', 'w+') {|f| f.write(output)}
