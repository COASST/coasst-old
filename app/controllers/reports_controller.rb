class ReportsController < ApplicationController
  layout 'plain'
  require 'gruff'

  helper :gruff


  skip_before_filter :verify_authenticity_token

  def index
  end

  def families_by_count
    # Get total count
    @families_count = Group.count

    all_species = Species.find(:all,:include=>:group)
    @family_by_id = {}
    # bit wasteful but oh well
    for s in all_species
      @family_by_id[s.group_id] = s.group
    end

    # TBD unknown AND group_id IS NOT NULL
    counts = Group.carcass_count_table("birds.refound IS FALSE")

    @min_year = 1999
    @max_year = Time.now.year

    # map hash to an array, sort the array based on count
    @sorted_counts = counts.sort_by_value
    @bird_count = 0
    counts.each do |k,v|
      @bird_count += v
    end
  end

  def species_by_count
    all_species = Species.find(:all)
    @species_by_id = {}
    for s in all_species
      @species_by_id[s.id] = s
    end

    # TBD unknown AND group_id IS NOT NULL
    counts = Species.carcass_count_table()

    # Get valid species count
    # XXX: -2 for Canada Goose dupes
    @species_count = counts.length - 2

    # map hash to an array, sort the array based on count
    @sorted_counts = counts.sort_by_value

    @bird_count = 0
    counts.each do |k,v|
      @bird_count += v
    end
    @min_year = 1999
    @max_year = Time.now.year
  end

  def species_by_count_by_year_inline
    render :update do |page|
      div_id = "graph-div-" + params[:year].to_s.downcase.gsub(" ","-")
      page.replace_html div_id, :partial=>"graph_image_link"
      page.visual_effect :blindDown, div_id, :duration => 1

    end
  end

  def species_by_count_by_year
    if params[:year] =~ /^\d{4}$/
      @year = params[:year].to_i
      per_year = 0
      @years = [@year]
    else
      @year = nil
      per_year = 10
      @years = (1999 .. Time.now.year).to_a
    end

    @counts_by_year = {}
    @full_counts_by_year = {}
    @totals_by_year = {}
    @species_by_id = {}
    @counts_by_year["All years"] = {}
    @top10_totals_by_year = {}

    all_species = Species.find(:all)
    @species_by_id = {}
    for s in all_species
      @species_by_id[s.id] = s
    end

    cumulative = {}
    @years.each do |year|
      conditions = "surveys.survey_date >= '#{year}-01-01' AND " +
        "surveys.survey_date <  '#{year+1}-01-01'"
      counts = Species.carcass_count_table(conditions)
      @totals_by_year[year] = counts.values.inject(0) {|sum,i| sum += i}

      # map hash to an array, sort the array based on count
      all_sorted_counts = counts.sort_by_value

      @top10_totals_by_year[year] = all_sorted_counts[0 .. 9].inject(0) {|sum,i| sum += i[1]}

      if @year.nil?
        @counts_by_year[year] = all_sorted_counts[0 .. 9]
      else
        @counts_by_year[year] = all_sorted_counts
      end

      counts.each do |species_id,count|
        if cumulative.has_key?(species_id)
          cumulative[species_id] += count
        else
          cumulative[species_id] = count
        end
      end
    end

    if @year.nil?
      all_sorted_cumulative_counts = cumulative.sort_by_value
      @counts_by_year["All Years"] = all_sorted_cumulative_counts[0 .. 9]
      @totals_by_year["All Years"] = cumulative.values.inject(0) {|sum,i| sum += i}
      top10_cumulative = all_sorted_cumulative_counts[0 .. 9]
      @top10_totals_by_year["All Years"] = top10_cumulative.inject(0) {|sum,i| sum += i[1]}
      @years << "All Years"
    else
      #conditions = "surveys.survey_date >= '#{@year}-01-01' AND " +
      #  "surveys.survey_date <  '#{@year+1}-01-01'"
      @total_count = Bird.carcass_count()
    end

    if params[:format] == "graph" and (params[:year] =~ /^\d{4}$/ || params[:year] == "All Years")
      year = params[:year] =~ /^\d{4}$/ ? params[:year].to_i : params[:year]
      g = Gruff::Pie.new("540x480")
      g.legend_font_size = 18

      g.title = "Species Found in "+year.to_s
      #g.data("other",total_misc)

      g.theme = {
        :colors => graph_colors(),
        :marker_color => 'white',
        :font_color => 'white',
        :background_colors => ['black', '#4a465a']
      }

      top10 = @counts_by_year[year][0 .. 9]
      for spp in top10
        count = spp[1]
        s = @species_by_id[spp[0]]
        g.data(s.name,count)
      end

      bird_count = @counts_by_year[year].length
      if bird_count > 10
        other = @counts_by_year[year][10 .. @counts_by_year[year].length]
        other_total = other.inject(0) {|sum,i| sum += i[1]}
        g.data("Other",other_total)
      end

      #render :text => @birds.to_csv(:only=>["survey_id","survey_date","beach_name","species_id","species_name"])
      send_data(g.to_blob,:disposition=>'inline',:type=>'image/png',:filename=>"oiled_species.png")
    end

    if params[:format] == "graph_google" and (params[:year] =~ /^\d{4}$/ || params[:year] == "All Years")
      year = params[:year] =~ /^\d{4}$/ ? params[:year].to_i : params[:year]
      require 'gchart'

      data = []

      top10 = @counts_by_year[year][0 .. 9]
      other = @counts_by_year[year][10 .. @counts_by_year[year].length]
      other_total = other.inject(0) {|sum,i| sum += i[1]}
      for spp in top10
        count = spp[1]
        s = @species_by_id[spp[0]]
        data.push([CGI.escape(s.name), count])
      end
      data.push(["Other", other_total])

      @gchart = Gchart.pie_3d(  :title => "Species Found in "+year.to_s, :size => '625x250',
                   :data => data.map {|k, v| v}, :labels => data.map {|k, v| k},
                   :line_colors => "156981,c4dae0", :format => 'img_tag')

    end
  end

  def oiled_birds
    @birds = Bird.find(:all, :conditions => "oil IS true AND refound IS false AND birds.verified IS true",
           :include => [{:survey=>:beach} , :species])

    @by_beach = {}
    @by_species = {}
    for b in @birds
      if @by_beach.has_key?(b.survey.beach)
        @by_beach[b.survey.beach] += 1
      else
        @by_beach[b.survey.beach] = 1
      end

      if @by_species.has_key?(b.species)
        @by_species[b.species] += 1
      else
        @by_species[b.species]  = 1
      end
    end
    @species_total =  Species.carcass_count_table()
    @beach_total = {}
    beaches = Bird.count(:conditions=>"refound IS false", :include=>:survey, :group=>"surveys.beach_id")
    beaches.each do |row|
      @beach_total[row[0].to_i] = row[1]
    end

    @total_oiled = @birds.length
    @total_birds = Bird.carcass_count()
  end

  def oiled_birds_by_year
    if params[:type] == "beach"
      @birds = Bird.find(:all, :conditions => "oil IS true AND refound IS false AND birds.verified IS TRUE",
             :include => [{:survey=>:beach}])
    else
      @birds = Bird.find(:all, :conditions => "oil IS true AND refound IS false AND birds.verified IS TRUE",
             :include => [:species])
    end

    @category_name = {}
    @by_year_by_type = {}
    @oiled_by_year = {}
    for b in @birds
      if params[:type] == "beach"
        key = b.survey.beach_id
        value = b.survey.beach
      else
        key = b.species_id
        value = b.species
      end
      year = b.survey.survey_date.year
      if @oiled_by_year.has_key?(year)
        @oiled_by_year[year] += 1
      else
        @oiled_by_year[year] = 1
        @by_year_by_type[year] = {}
      end
      if @by_year_by_type[year].has_key?(key)
        @by_year_by_type[year][key] += 1
      else
        @by_year_by_type[year][key] = 1
        @category_name[key] = (value.nil?) ? nil : value.name
      end
    end

    @total_oiled = 0
    @oiled_by_year.each do |year,subtotal|
      @total_oiled += subtotal
    end

    @total_by_year_by_type = Bird.total_by_year(params[:type])

    @total_by_year = {}
    @total_by_year_by_type.each do |year, results|
      @total_by_year[year] = 0
      results.each do |link_id, count|
        @total_by_year[year] += count
      end
    end

    @total_birds = Bird.carcass_count

    @years = @oiled_by_year.keys.sort.reverse
  end

  def entangled_birds
    @birds = Bird.find(:all, :conditions => "entangled != 'Not' AND refound IS false AND birds.verified IS true",
           :include => [{:survey=>:beach} , :species])

    @by_beach = {}
    @by_species = {}
    @by_entanglement = {}
    for b in @birds
      if @by_beach.has_key?(b.survey.beach)
        @by_beach[b.survey.beach] += 1
      else
        @by_beach[b.survey.beach] = 1
      end

      if @by_species.has_key?(b.species)
        @by_species[b.species] += 1
      else
        @by_species[b.species]  = 1
      end
      if @by_entanglement.has_key?(b.entangled)
        @by_entanglement[b.entangled] += 1
      else
        @by_entanglement[b.entangled] = 1
      end
    end

    @species_total =  Species.carcass_count_table()
    @beach_total = {}
    beaches = Bird.count(:conditions=>"refound IS false", :include=>:survey, :group=>"surveys.beach_id")
    beaches.each do |row|
      @beach_total[row[0].to_i] = row[1]
    end

    @total_entangled = @birds.length

    @total_birds = Bird.carcass_count()
  end

  def entangled_birds_by_year
    if params[:type] == "beach"
      includes = {:survey=>:beach}
    else
      includes =  :species
    end
       @birds = Bird.find(:all,
             :conditions => "entangled != 'Not' AND refound IS false AND birds.verified IS true",
             :include => [includes])

    @category_name = {}
    @by_year_by_type = {}
    @entangled_by_year = {}
    for b in @birds
      if params[:type] == "beach"
        key = b.survey.beach_id
        value = b.survey.beach
      else
        key = b.species_id
        value = b.species
      end
      year = b.survey.survey_date.year
      if @entangled_by_year.has_key?(year)
        @entangled_by_year[year] += 1
      else
        @entangled_by_year[year] = 1
        @by_year_by_type[year] = {}
      end
      if @by_year_by_type[year].has_key?(key)
        @by_year_by_type[year][key] += 1
      else
        @by_year_by_type[year][key] = 1
        @category_name[key] = (value.nil?) ? nil : value.name
      end
    end

    @total_entangled = 0
    @entangled_by_year.each do |year,subtotal|
      @total_entangled += subtotal
    end

    @total_by_year_by_type = Bird.total_by_year(params[:type])

    @total_by_year = {}
    @total_by_year_by_type.each do |year, results|
      @total_by_year[year] = 0
      results.each do |link_id, count|
        @total_by_year[year] += count
      end
    end

    @total_birds = Bird.carcass_count

    @years = @entangled_by_year.keys.sort.reverse
  end

  def entangled_list
    entanglement = params[:id]
    @birds = Bird.find(:all, :conditions => ["entangled != 'Not' AND entangled = ? AND refound IS false", entanglement],
      :include => [{:survey=>:beach}, :species])
    @birds.sort! {|a,b| b.survey.survey_date <=> a.survey.survey_date}
  end

  def species_of_concern
    id = params[:id]
    if not id.nil?
      species_of_concern_category(id)
    else
      species_of_concern_list
    end
  end

  def species_of_concern_category(concern_id)
    @id = concern_id
    @concern = Concern.find(@id, :include => :species)
    @year = nil
    per_year = 10
    @years = (1999 .. Time.now.year).to_a

    @counts_by_year = {}
    @full_counts_by_year = {}
    @totals_by_year = {}
    @species_by_id = {}
    @counts_by_year["All Years"] = {}
    @counts_by_year_by_species = {}

    @all_species = @concern.species
    @species_by_id = {}
    for s in @all_species
      @species_by_id[s.id] = s
    end

    all_beaches = []
    if not @concern.name.downcase.include?("Fed")
      state = @concern.name.split(" ")[0]
      state_obj = State.find(:first,:conditions=>["name=?",state])
      if state_obj
        beaches = Beach.find(:all,:conditions=>["state_id=?",state_obj.id])
        beaches.each do |b|
          all_beaches << b.id
        end
      end
    end

    cumulative = {}
    @years.each do |year|
      @conditions = "surveys.survey_date >= '#{year}-01-01' AND " +
        "surveys.survey_date <  '#{year+1}-01-01'"
      if not all_beaches.empty?
        @conditions += " AND surveys.beach_id IN ("+all_beaches.join(", ")+")"
      end
      @all_birds_conditions = @conditions
      @conditions += " AND birds.species_id IN ("+@all_species.map{|s| s.id}.join(",")+")"
      counts = Species.carcass_count_table(@conditions)
      @counts_by_year_by_species[year] = counts

      @totals_by_year[year] = counts.values.inject(0) {|sum,i| sum += i}

      all_counts = Bird.carcass_count(@all_birds_conditions)
      @full_counts_by_year[year] = all_counts

      # map hash to an array, sort the array based on count
      all_sorted_counts = counts.sort_by_value

      @counts_by_year[year] = all_sorted_counts
      counts.each do |species_id,count|
        next if species_id==Species::UNKNOWN_ID
        if cumulative.has_key?(species_id)
          cumulative[species_id] += count
        else
          cumulative[species_id] = count
        end
      end
    end

    @totals_by_year["All Years"] = cumulative.values.inject(0) {|sum,i| sum += i}

    all_years_count_table = {}
    @counts_by_year_by_species.each {|year,arr|
      arr.each { |species_id,cnt|
        if not all_years_count_table.has_key? species_id
          all_years_count_table[species_id] = 0
        end
        all_years_count_table[species_id] += cnt
      }
    }
    @counts_by_year_by_species["All Years"] = all_years_count_table
    @full_counts_by_year["All Years"] = Bird.carcass_count()
    @years << "All Years"
    @species_count = all_years_count_table.select {|k, v| v > 0}.length
  end

  def species_of_concern_list
    @concerned_spp = {}
    @concerns = Concern.find(:all, :include => :species)
    mapped = @concerns.map do |c|
      # sort_by makes 0 before 1, we want federal to always be at the top
      not_federal = c.name =~ /federal/i ? 0 : 1

      rank = c.name =~ /endangered/i ? 1 :
             c.name =~ /threatened/i ? 2 :
             c.name =~ /sensitive/i ? 3 :
             c.name =~ /concern/i ? 4 : 5

      if not_federal == 0
        state = "federal" # all lowercase, will be ordered first
      else
        state = c.name.split(" ")[0]
      end
      [c,not_federal,state,rank]
    end

    # can't just use sort method with overloading, since it'll resort the map...
    # sort_by retains order and accepts ranked priority
    @concerns = mapped.sort_by {|a| [a[1], a[2], a[3]]}.map {|a| a[0]}

    @concerns.each do |c|
      c.species.each {|s|
        if @concerned_spp.has_key?(s)
          @concerned_spp[s] += 1
        else
          @concerned_spp[s] = 1
        end
      }
    end
  end

  def deposition_indices
    @deposition_rate = {}
    # replicate logic found in 'docs/from_kate/choice species deposition_jan07.sas'...
  end

  def graph_colors
    @blue = '#6886B4'
    @yellow = '#FDD84E'
    @green = '#72AE6E'
    @red = '#D1695E'
    @purple = '#8A6EAF'
    @orange = '#EFAA43'
    @white = 'white'
    @colors = [@yellow, @blue, @green, @red, @purple, @orange, @white,
      '#88a736', '#e57c4b','#b87da8', '#56a597']
  end
end
