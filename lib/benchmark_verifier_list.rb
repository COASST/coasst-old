require 'benchmark'

Benchmark.bm do |x|
		## overall beach listing tests
    #x.report {@beaches = Beach.find(:all, :include => [:region, :state, :surveys],
    #                     :conditions => ['monitored is TRUE'])}
		x.report {Survey.find(:all, :conditions => 'is_complete is TRUE and verified is FALSE', :order => 'survey_date DESC')}

		x.report {@beaches = Beach.find(:all, :include => [:region, :state], :conditions => ['monitored is TRUE'])}
		x.report {@unreviewed = Survey.find(:all, :conditions => ['verified is false'])}
		x.report {@unreviewed = Survey.find_by_sql("SELECT beach_id, COUNT(beach_id) FROM surveys WHERE verified IS false GROUP BY beach_id").map_to_hash {|s| {s.beach_id => s.count}} }
		#puts @unreviewed.to_yaml
    #@unreviewed = {}
    #x.report {
    #  @beaches.each do |b|
    #    @unreviewed[b.id] = b.surveys.select {|s| s.verified == false}.length  
    #  end
    #}
		
		## beach detail view tests
		#
		# beach 50 is our worst case (313 surveys)
		x.report {@beach = Beach.find(50, :include => [{:surveys => :birds}])}
		x.report {
			@beach2 = Beach.find_by_sql("SELECT * FROM beaches b LEFT JOIN surveys s ON b.id = s.beach_id WHERE b.id = 50")
			surveys = @beach2.map{|br| br.id}.join(", ")
			birds = Bird.find_by_sql("SELECT * FROM birds where survey_id IN (#{surveys})")
		}

		@unreviewed_surveys = []
    @reviewed_surveys = []
		x.report {
		@beach.surveys.each do |s|
      verified = s.verified
      s.birds.each do |b|
        if b.verified == false
          verified = false
        end
      end
      
      if verified == false 
        @unreviewed_surveys << s
      else
        @reviewed_surveys << s
      end
    end
		}
		@rev_copy = @reviewed_surveys.dup
		x.report {@reviewed_surveys.sort! {|a,b| b.survey_date <=> a.survey_date}}

		x.report {@rev_copy.sort_by {|a| a.survey_date}.reverse!}
end
