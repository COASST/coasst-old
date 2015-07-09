class SearchController < ApplicationController
  require 'csv'
  layout 'search'

  # this is just jacked from data_controller, merge these?
  def poll_date
    parsed_date = Date.parse(params[:date])
    date = parsed_date.to_s(:survey)
  end

  def index
    search_form
  end

  def submit
    search_form

    passed_in = []
    joins = {}
    tables = ["beaches","surveys"]
    left_joins = []
    conditions = ["surveys.beach_id=beaches.id"]
    fields = ["birds.id","surveys.id AS survey_id"]
    @columns = []


    @aggregate_when = params[:aggregate_when] == "true" ? true : false
    @aggregate_where = params[:aggregate_where] == "true" ? true : false
    @aggregate_bird = params[:aggregate_bird] == "true" ? true : false

    state_ids = param_to_i('states')
    region_ids = param_to_i('regions')
    beach_ids = param_to_i('beaches')

    @where_group_by = ""
    if beach_ids.length > 0
      fields << "surveys.beach_id" << "beaches.name AS beach_name"
      if @aggregate_where
        @columns << "beach_id" << "beach_name"
        @where_group_by = "beach_id"
      end
      conditions << "surveys.beach_id IN (?)"
      passed_in << beach_ids
    elsif region_ids.length > 0
      tables <<  "regions"
      conditions << "regions.id = beaches.region_id"
      fields << "beaches.region_id, regions.name AS region_name"
      if @aggregate_where
        @columns << "region_id" << "region_name"
        @where_group_by = "region_id"
      end
      conditions << "beaches.region_id IN (?)"
      passed_in << region_ids
    elsif state_ids.length > 0
      tables << "regions"
      conditions << "regions.id = beaches.region_id"
      left_joins << "LEFT JOIN states ON regions.state_id = states.id"
      fields << "regions.state_id, states.name as state_name"
      if @aggregate_where
        @columns << "state_id" << "state_name"
        @where_group_by = "state_id"
      end
      conditions << "regions.state_id IN (?)"
      passed_in << state_ids
    end

    species_ids = param_to_i('species')
    subgroup_ids = param_to_i('subgroups')
    group_ids = param_to_i('groups')
    foot_type_family_ids = param_to_i('foot_type_families')

    @bird_group_by = ""
    if species_ids.length > 0
      tables << "birds" << "species"
      conditions << "birds.survey_id = surveys.id" << "birds.species_id = species.id"
      fields << "species.id AS species_id" << "species.name AS species_name"
      if @aggregate_bird
        @columns << "species_id" << "species_name"
        @bird_group_by = "species_id"
      end
      conditions << "species.id IN (?)"
      passed_in << species_ids
    elsif subgroup_ids.length > 0
      tables << "birds" << "species"
      conditions << "birds.survey_id = surveys.id" << "birds.species_id = species.id"
      left_joins << "LEFT JOIN subgroups ON species.subgroup_id = subgroups.id"
      fields << "species.subgroup_id" << "subgroups.name AS subgroup_name"
      if @aggregate_bird
        @columns << "subgroup_id" << "subgroup_name"
        @bird_group_by = "subgroup_id"
      end
      conditions << "species.subgroup_id IN (?)"
      passed_in << subgroup_ids
    elsif group_ids.length > 0
      tables << "birds" << "species"
      conditions << "birds.survey_id = surveys.id" << "birds.species_id = species.id"
      left_joins << "LEFT JOIN groups ON species.group_id = groups.id"
      fields << "species.group_id" << "groups.name AS group_name"
      if @aggregate_bird
        @columns << "group_id" << "group_name"
        @bird_group_by = "group_id"
      end
      conditions << "species.group_id IN (?)"
      passed_in << group_ids
    elsif foot_type_family_ids.length > 0
      tables << "birds" << "species"
      conditions << "birds.survey_id = surveys.id" << "birds.species_id = species.id"
      left_joins << "LEFT JOIN foot_type_families ON species.foot_type_family_id = foot_type_families.id"
      fields << "species.foot_type_family_id" << "foot_type_families.name AS foot_type_family_name"
      if @aggregate_bird
        @columns << "foot_type_family_id" << "foot_type_family_name"
        @bird_group_by = "foot_type_family_id"
      end
      conditions << "species.foot_type_family_id IN (?)"
      passed_in << foot_type_family_ids
    end


    # TBD if "by_season" is selected, the year should be offset upward by one month
    # i.e. 2007 ends january 31 2008 cause the "winter" season goes to january
    if params["end"]["month"].empty? and not params["start"]["month"].empty?
      params["end"]["month"] = params["start"]["month"]
    end
    if params["end"]["year"].empty? and not params["start"]["year"].empty?
      params["end"]["year"] = params["start"]["year"]
    end
    if not params["start"]["year"].empty?
      start_month = params["start"]["month"].empty? ? 1 : params["start"]["month"].to_i
      start_time = Date.civil(params["start"]["year"].to_i,start_month,1)
      conditions << "surveys.survey_date >= '#{start_time.year}-#{start_time.month}-#{start_time.day}'"
    end

    if not params["end"]["year"].empty?
      end_month = params["end"]["month"].empty? ? 12 : params["end"]["month"].to_i
      end_time = Date.civil(params["end"]["year"].to_i,end_month,-1)
      conditions << "surveys.survey_date <= '#{end_time.year}-#{end_time.month}-#{end_time.day}'"
    end

    if params[:when_group_by] == "yearly"
      fields << "to_char(survey_date,'YYYY') AS year"
      if @aggregate_when
        @columns <<  "year"
        @when_group_by = ["year"]
      end
    elsif params[:when_group_by] == "monthly"
      fields << "to_char(survey_date,'YYYY') AS year"
      fields << "to_char(survey_date,'MM') AS month"
      if @aggregate_when
        @columns <<  "year"
        @columns <<  "month"
        @when_group_by = ["year","month"]
      end
    elsif params[:when_group_by] == "by season"
      fields << "(CASE WHEN EXTRACT(month FROM survey_date) <= 1 THEN (EXTRACT(year FROM survey_date) - 1) ELSE EXTRACT(year FROM survey_date) END) AS year"
      season = "CASE WHEN EXTRACT(month FROM survey_date) <= 1 THEN 'Winter'"
      season += " WHEN EXTRACT(month FROM survey_date) <= 4 THEN 'Spring'"
      season += " WHEN EXTRACT(month FROM survey_date) <= 7 THEN 'Summer'"
      season += " WHEN EXTRACT(month FROM survey_date) <= 10 THEN 'Fall'"
      season += " ELSE 'Winter' END"
      season = "(" + season + ") AS season"
      fields << season
      if @aggregate_when
        @columns <<  "year"
        @columns <<  "season"
        @when_group_by = ["year","season"]
      end
    else
      @when_group_by = []
    end

    conditions << "(surveys.is_complete IS true OR surveys.is_complete IS NULL)"
    conditions << "(birds.refound IS false OR birds.refound IS NULL)"

    @sql = "SELECT "+fields.join(", ")
    @sql += " FROM " + tables.join(" CROSS JOIN ")
    if not tables.include? "birds"
      @sql += " LEFT JOIN birds ON birds.survey_id = surveys.id"
      @sql += " LEFT JOIN species ON birds.species_id = species.id"
    end
    @sql += " " + left_joins.join(" ")
    @sql += " WHERE " + conditions.join(" AND ")
    @birds  = Bird.find_by_sql([@sql] + passed_in)

    group_by = []
    if not @when_group_by.blank?
      group_by += @when_group_by
    end
    if not @where_group_by.blank?
      group_by << @where_group_by
    end
    if not @bird_group_by.blank?
      group_by << @bird_group_by
    end


    @bird_counter = {}
    @survey_counter = {}
    @row_by_hash = {}
    @seen_survey = {}
    @surveys_by_hash = {}
    for b in @birds
      hash_values = []
      for g in group_by
        hash_values << b.send(g)
      end
      hash = hash_values.join("|")
      if not b.id.nil?
        if @bird_counter.has_key? hash
          @bird_counter[hash] += 1
        else
          @bird_counter[hash] = 1
          @row_by_hash[hash] = b
        end
      end

      if @survey_counter.has_key?(hash)
        if not @seen_survey.has_key?(b.survey_id)
          @survey_counter[hash] += 1
        end
      else
        if not @seen_survey.has_key?(b.survey_id)
          @survey_counter[hash] = 1
          @row_by_hash[hash] = b
        end
      end

      if not @surveys_by_hash.has_key? hash
        @surveys_by_hash[hash] = {}
      end
      if not @surveys_by_hash[hash].has_key? b.survey_id
        @surveys_by_hash[hash][b.survey_id] = 0
      end
      @surveys_by_hash[hash][b.survey_id] += 1
      @seen_survey[b.survey_id] = true
    end

    @data = []
    @survey_count = 0
    @bird_count = 0
    @row_by_hash.each do |hash,b|
      #b = @row_by_hash[hash]
      row = []

      for c in @columns
        row << b.send(c)
      end

      if @bird_counter.has_key?(hash)
        row << @bird_counter[hash]
        @bird_count += @bird_counter[hash]
      else
        row << 0
      end

      count_for_hash = @surveys_by_hash[hash].keys.length
      row << count_for_hash

      #unique_count = @survey_counter[hash]
      #@survey_count += unique_count if not unique_count.nil?
      @survey_count = @seen_survey.keys.length
      @data << row
    end

    @columns << "bird_count" << "survey_count"
    @data = @data.sort_by {|a|
      key = []
      @columns.each_with_index { |c,i|
        key << a[i] if c !~ /id$|count$/
      }
      key
    }

    if params["submit"].downcase == "download as csv"
      response.headers['Content-Type'] = 'text/csv; charset=iso-8859-1; header=present'
      response.headers['Content-Disposition'] = "attachment; filename=birds_#{Time.now.strftime("%m-%d-%Y")}.csv"
      @csv = ''
      CSV::Writer.generate(@csv, ",") do |csv|
        csv << @columns
        for row in @data
          csv << row
        end
        totals = Array.new(@columns.length)
        totals[-3] = "TOTAL"
        totals[-2] = @bird_count
        totals[-1] = @survey_count
      end
      render :text => @csv
    end
  end

  def search_form
    if params.has_key? :start
      @start_month = params[:start][:month].to_i
      @start_year  = params[:start][:year].to_i
      @end_month = params[:end][:month].to_i
      @end_year = params[:end][:year].to_i
    end

    defaults = [["All", ""]]
    @aggregate_when = params[:aggregate_when] || true
    @aggregate_where = params[:aggregate_where] || true
    @aggregate_bird = params[:aggregate_bird] || true

    @regions_db = Region.find_active_regions
    @regions = defaults
    @regions += @regions_db.map {|u| [u.name, u.id.to_s]}.sort {|a,b| a[0] <=> b[0]}

    params["regions"] = [""] unless params.has_key?("regions")

    @states_db = State.current_states
    @states = defaults
    @states += @states_db.map {|u| [u.name, u.id.to_s]}.sort {|a,b| a[0] <=> b[0]}
    params["states"] = [""] unless params.has_key?("states")

    @beaches_db = Beach.find_active_beaches
    @beaches = defaults
    @beaches += @beaches_db.map {|u| [u.name, u.id.to_s]}.sort {|a,b| a[0] <=> b[0]}
    params["beaches"] = [""] unless params.has_key?("beaches")

    @foot_type_families_db = FootTypeFamily.find(:all,:conditions=>{:active=>true})
    @foot_type_families = defaults
    @foot_type_families += @foot_type_families_db.map {|u| [u.name, u.id.to_s]}
    params["foot_type_families"] = [""] unless params.has_key?("foot_type_families")

    @groups_db = Group.find(:all,:conditions=>{:active=>true})
    @groups = defaults
    @groups += @groups_db.map {|u| [u.name, u.id.to_s]}
    params["groups"] = [""] unless params.has_key?("groups")

    @subgroups_db = Subgroup.find(:all)
    @subgroups = defaults
    @subgroups += @subgroups_db.map {|u| [u.name, u.id.to_s]}
    params["subgroups"] = [""] unless params.has_key?("subgroups")

    @species_db = Species.find(:all,:conditions=>{:active=>true})
    @species = defaults
    @species += @species_db.map {|u| [u.name, u.id.to_s]}
    params["species"] = [""] unless params.has_key?("species")

    @beaches_by_region  = make_id_hash(@beaches_db,:region_id)
    @regions_by_state   = make_id_hash(@regions_db,:state_id)
    @groups_by_ftf       = make_id_hash(@groups_db,:foot_type_family_id)
    @subgroups_by_group  = make_id_hash(@subgroups_db,:group_id)
    @species_by_subgroup = make_id_hash(@species_db,:subgroup_id)
    @species_by_group    = make_id_hash(@species_db,:group_id)
  end

  protected

  def make_id_hash(objects_array, map_to_key)
    mapping_hash = {}
    objects_array.each do |o|
      value = o.send(map_to_key)
      if not value.nil?
        if mapping_hash.has_key? value
          mapping_hash[value] << o.id
        else
          mapping_hash[value] = [o.id]
        end
      end
    end
    return mapping_hash
  end

  def param_to_i (param_name)
    if params[param_name]:
      params[param_name].grep(/^\d+$/).map{|u| u.to_i}
    end
  end

end
