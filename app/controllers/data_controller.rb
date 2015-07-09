class DataController < ApplicationController

  # force activerecord object counting
  include Oink::InstanceTypeCounter

  include DataHelper
  layout 'entry_stages'

  before_filter :check_authentication
  verify :method => :post,
         :only => [:submit_step_who, :submit_step_when, :submit_step_beach, :submit_step_birds],
         :redirect_to => { :action => :list_data }

  verify :method => :post,
         :only => [:remove_volunteer_from_survey],
         :redirect_to => {:action => :enter_data}

  protect_from_forgery :only => [:create, :update, :destroy]

  def index
    v = Volunteer.find(session[:volunteer_id])
    if v.has_role?(['verifier', 'intern'])
      @volunteer_surveys = {}
      list_regions
    else
      list_data
    end
  end

  def enter_data
    if params.has_key?(:id) and params[:id].to_i > 0
      session[:survey] = Survey.find(params[:id])
    end
    @survey = get_session_survey

    @step = guess_step(@survey)
    @step_tags = step_tags(@step, @survey.step)
    @step_urls = step_urls(@survey.step)
    @step_page = step_page(@step)

    self.send(@step_page)
    render :action => @step_page, :layout => "entry_stages"
  end

  def step_who
    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    @submit = submission_data(@step)
    @survey = @survey.reload unless @survey.id.blank?

    if @submitter
      @friends = @submitter.friends.sort_by {|a| a.fullname}
    end

    if not @submitter.has_role?('verifier') and @step == 1
      if not @survey.all_volunteers('submitter').include?(@submitter)
        @survey.add_volunteer(@submitter, 'submitter')
      end
      # if a volunteer registering their own data, add them as a data collector
      if not @survey.all_volunteers('data collector').include?(@submitter) \
         and not @submitter.has_role?(['intern', 'verifier'])
        @survey.add_volunteer(@submitter)
      end
    end
    # volunteers had multiple roles, but now collapsed under this label
    @surveyor = 'data collector'
    @volunteers = @survey.all_volunteers
  end

  def submit_step_who
    @survey = get_session_survey
    @submitter = Volunteer.find_by_id(session[:volunteer_id])

    if @survey.valid_step?(1)
      @survey.step = 2 if @survey.step < 3
      @survey.errors.clear
      if @survey.is_complete? and not @submitter.has_role?('verifier')
        flash[:notice] = "Updated data collectors successfully"
        redirect_to(:controller => :survey, :action => :show, :id => @survey.id)
      else
        if @submitter.has_role?('verifier')
          flash[:notice] = 'Data collectors verified'
        end
        redirect_to_entry(nil,2,:error)
      end
    else
      redirect_to_entry(error_messages_for_step(1),1,:error)
    end
  end

  def step_when
    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    @submit = submission_data(@step)

    @start_time = short_time(@survey.start_time)
    @end_time   = short_time(@survey.end_time)

    if not @survey.start_time.nil? and not @survey.end_time.nil?
      @selected_time = ""
    else
      @selected_time = "None given"
    end

    if not @survey.survey_date.nil?
      @selected_date = @survey.survey_date.to_s(:survey)
    else
      @selected_date = "None selected"
    end
  end

  def submit_step_when
    @survey = get_session_survey
    @survey.survey_date = Time.now.smart_parse(params[:survey][:survey_date], nil, false, 'date')
    @submitter = Volunteer.find_by_id(session[:volunteer_id])

    if not @survey.survey_date.nil?
      start_time,end_time = survey_times(params[:survey][:start_time], params[:survey][:end_time], @survey.survey_date)
      @survey.start_time = start_time
      @survey.end_time = end_time
    end

    next_step = 3
    klass = nil
    if @survey.is_complete
      if @survey.valid?
        if @submitter.has_role?('verifier')
          message = 'Survey time verified'
        else
          message = "Changed survey time sucessfully"
        end

        @survey.save
      else
        message = error_messages_for_survey
        klass = :error
        next_step = 2
      end
    else
      # TODO VALIDATION AGAINST FOUND SURVEYS:
      # @existing_survey = find surveys in range where volunters in (volunteer_list), check time match
      if @survey.valid_step?(2)
        message = "Added survey time successfully"

        @survey.step = 3 if @survey.step < 3
        @survey.errors.clear
      else
        message = error_messages_for_step 2
        klass = :error
        next_step = 2
      end
    end

    if @survey.is_complete? and @survey.valid? \
      and not @submitter.has_role?('verifier')
      flash[:notice] = message
      redirect_to(:controller => :survey, :action => :show, :id => @survey.id)
    else
      redirect_to_entry(message,next_step,klass)
    end
  end

  def step_beach
    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    @submit = submission_data(@step)

    # XXX move this to somewhere appropriate
    if @submitter.has_role?('verifier')
      @role = 'admin'
    else
      @role = 'volunteer'
    end

    @beaches = @submitter.beaches
    @weather = Survey::Weather
    @oil_types = Survey::OilTypes
    @has_tracks = @survey.has_tracks?

    if not @survey.beach_id.nil?
      b = Beach.find(@survey.beach_id)
      @selected_beach = b.name
    elsif @beaches.length == 1
      @selected_beach = @beaches[0].name
    else
      @selected_beach = 'None Selected'
    end

    if @submitter.has_role?(["intern", "verifier"])
      @beach = @survey.beach
    end

    setup_tracks
    guess_travel_times(@survey,@survey.beach_id)

    @oil_type_ids = []
  end

  def setup_tracks
    tracks_by_class = {}
    for s in @survey.survey_tracks
      tracks_by_class[s.track_type] = s
    end
    classes = SurveyTrack::TrackClass.map {|a| a[1]}

    @tracks = []
    classes.each do |cl|
      if tracks_by_class.has_key?(cl)
        track = tracks_by_class[cl]
      else
        track = SurveyTrack.new(:track_type=>cl)
      end
      @tracks << track
    end
  end

  def guess_travel_times(survey,beach_id)
    submitter = Volunteer.find_by_id(session[:volunteer_id])
    survey_volunteers  = survey.all_survey_volunteers('data collector')
    @travel_time = []
    seen_volunteer = {}
    for sv in survey_volunteers
      time_in_minutes = nil
      if not sv.travel_time.nil?
        time_in_minutes = sv.travel_time
      else
        if not submitter.has_role?('verifier') # never guess when verifying
          time_in_minutes = SurveyVolunteer.last_travel_time(sv.volunteer_id,beach_id)
        end
      end

      unless seen_volunteer[sv.volunteer.id] == 1
        @travel_time << {:id=>sv.volunteer.id,:name=>sv.volunteer.name.to_s,:travel_time=>time_in_minutes}
        seen_volunteer[sv.volunteer.id] = 1
      end
    end
  end

  # prevent duplicate survey entry, by checking for any other surveys with the
  # same volunteer, beach and time
  def check_for_duplicate_survey(survey, beach_id)
    volunteers = survey.all_survey_volunteers('data collector').map {|s| s.volunteer_id}
    duplicate = Survey.find_by_sql ["SELECT s.id FROM surveys s LEFT JOIN survey_volunteers sv ON
      s.id = sv.survey_id WHERE sv.volunteer_id IN (?) AND s.beach_id = ? AND s.survey_date = ?",
      volunteers, beach_id, survey.survey_date]

    if duplicate.blank?
      nil
    else
      survey_id = survey.id
      dupe_id = duplicate.first.id
      logger.info("dupe: #{dupe_id} survey: #{survey_id}")
      # skip if it's the active survey (editing existing survey)
      if survey_id == dupe_id
        nil
      else
        dupe_id
      end
    end
  end

  def submit_step_beach
    @survey = get_session_survey
    @survey.attributes = params[:survey]
    @submitter = Volunteer.find_by_id(session[:volunteer_id])

    next_step = 4
    klass = nil
    if @survey.is_complete
      if @survey.valid?
        message = "Changed beach data sucessfully"
        if @submitter.has_role?('verifier')
          message = "Beach verification completed"
          @survey.verified = true
        end
        @survey.save
      else
        message = error_messages_for_survey
        klass = :error
        next_step = 3
      end
    else
      if @survey.valid_step?(3)
        message = "Added beach data successfully"
        @survey.step = 4 if @survey.step < 4

        if @survey.valid?
          @survey.save
        else
          message = error_messages_for_survey
          next_step = 3
        end
      else
        message =  error_messages_for_step 3
        klass = :error
        next_step = 3
      end
    end

    # write out data to join tables
    save_travel_times
    save_tracks

    if @survey.is_complete? and @survey.valid? \
      and not @submitter.has_role?('verifier')
      flash[:notice] = message
      redirect_to(:controller => :survey, :action => :show, :id => @survey.id)
    else
      redirect_to_entry(message,next_step,klass)
    end
  end

  def submit_step_birds
    @survey = get_session_survey
    @survey.is_complete = true
    @survey.save

    @submitter = Volunteer.find_by_id(session[:volunteer_id])

    if @submitter.has_role?('verifier')
      flash[:notice] = "Verification complete on survey (code #{@survey.code})"
      if !@survey.beach_id.nil?
        redirect_to :action => :verification_beach, :id => @survey.beach_id
      else
        flash[:error] = "Unable to determine beach, returning to Verify Data"
        redirect_to :action => :index
      end
    else
      flash[:notice] = "Review your survey entry"
      redirect_to :action => :show, :id => @survey.id, :controller => :survey
    end
  end

  def save_travel_times
    survey_volunteers = @survey.all_survey_volunteers
    travel_time = params[:travel_time]
    for sv in survey_volunteers
      if travel_time && travel_time.has_key?(sv.volunteer_id.to_s)
        time_in_minutes = SurveyVolunteer.parse_travel_time(travel_time[sv.volunteer_id.to_s])
        if time_in_minutes.nil? or time_in_minutes < 0:
          sv.travel_time = nil
        else
          sv.travel_time = time_in_minutes
        end
        sv.save unless sv.survey_id.nil?
      end
    end
  end

  def save_tracks
    tracks_in_survey = {}
    for s in @survey.survey_tracks
      tracks_in_survey[s.track_type] = s
    end

    classes = SurveyTrack::TrackClass.map {|a| a[1]}

    classes.each do |cl|
      if tracks_in_survey.has_key?(cl)
        in_db = tracks_in_survey[cl]
        in_db.attributes = params[:survey_track][cl]
        if not params[:survey_track][cl].has_key?('present')
          in_db.present = false
        end

        # occasionally submissions generate a NULL response, when
        # the survey_id isn't sent correctly. Ignore these requests
        if in_db.has_data? and !@survey.id.nil?
          in_db.save
        else
          in_db.destroy
        end
      else
        new_st = SurveyTrack.new(params[:survey_track][cl])
        new_st.survey_id = @survey.id
        new_st.track_type = cl

        if new_st.has_data?
          @survey.survey_tracks << new_st
          if not @survey.id.nil?
            new_st.save
          end
        end
      end
    end
    @survey.reload unless @survey.id.nil?
  end

  def step_birds
    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    @survey.reload unless @survey.id.blank?
    @birds = @survey.birds.sort {|a, b| a.id <=> b.id}
  end

  def step_not_survey
    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    if @submitter.has_role?('verifier')
      @msg = ''
      @survey = Survey.find(params[:id])
      if params[:status] == 'not_survey'
        @survey.is_survey = false
        @msg = 'not'
      else
        @survey.is_survey = true
      end

      @survey.save
      if !@survey.beach_id.nil?
        flash[:notice] = "Updated to #{@msg} a survey"
        redirect_to :action => :verification_beach, :id => @survey.beach_id
      else
        flash[:error] = "Unable to determine beach, returning to Verify Data"
        redirect_to :action => :index
      end
    else
      flash[:notice] = "Invalid request"
      redirect_to :action => :enter_data, :s => 1
    end
  end

  def new_bird
    @bird = (@bird.nil?) ? Bird.new(params[:bird]) : @bird
    @survey = (@bird.survey) ? @bird.survey : get_session_survey

    @step = 4
    @step_tags = step_tags(4,4)
    @step_urls = step_urls(4)

    survey_birds = @survey.birds
    @index = (survey_birds.size + 1).to_s
    setup_taxonomy_selects
    update_species_section
  end

  def edit_bird
    @bird = (@bird.nil?) ? Bird.find(params[:id]) : @bird
    @survey = (@bird.survey) ? @bird.survey : get_session_survey

    @step = 4
    @step_tags = step_tags(4,4)
    @step_urls = step_urls(4)

    survey_birds = @survey.birds.sort! {|a, b| a.id <=> b.id}.map {|b| b.id}
    @index = "#{(survey_birds.rindex(@bird.id) + 1).to_s} of #{survey_birds.size.to_s}"

    # fix for unpopulated foot_type_family fields, also probably a good idea anyways
    # this makes sure the subgroup/group/ftf match the species if the species is not known
    @bird.resolve_classification!

    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    if @submitter.has_role?('verifier')
      @refind = @bird.previous_find
      if not @refind.nil?
        @refind_asp = ""
        if not @refind.age.nil?
          @refind_asp << @refind.age.name.capitalize
        end
        if not @refind.sex.nil?
          @refind_asp << " " + @refind.sex.capitalize
        end
        if not @refind.plumage.nil?
          @refind_asp << ", " + @refind.plumage.name.capitalize
        end
        @refind_parts = bird_length_attributes(@refind)
        refind_age = time_diff_in_days(@refind.survey.survey_date.to_time.to_i, @survey.survey_date.to_time.to_i)
        @refind_data = {
          :bird => @refind,
          :asp => @refind_asp,
          :parts => @refind_parts,
          :age => refind_age
        }
      end
    end

    setup_taxonomy_selects
    update_species_section
  end

  def setup_taxonomy_selects
    #note that group is handled in update_species_section
    @families =  FootTypeFamily.find(:all,:include=>:groups)
    @families_options = []
    @families.each do |f|
      subfamilies = f.groups.select { |g| g.composite }
      unless subfamilies.length == f.groups.length and subfamilies.length > 0
        name = f.name
        if not f.description.nil?
          name += " (" + f.description + ")"
        end
        # Unknown should be the first entry
        if f.name =~ /unknown/i
          @families_options.unshift([name, f.id])
        elsif f.name !~ /feet missing/i
          @families_options << [name,f.id]
        end
      end

      subfamilies.each do |sf|
        name = f.name + ": " + sf.name
        if not sf.description.nil?
          name += " (" + sf.description + ")"
        end
        @families_options << [name,-1*sf.id]
      end
    end
    @families_options.unshift []

    if @bird.group and @bird.group.composite?
      @foot_type_family_id = -1*@bird.group_id
    else
      @foot_type_family_id = @bird.foot_type_family_id
    end

    if @foot_type_family_id == FootTypeFamily::FEET_MISSING_ID
      @foot_type_family_id = FootTypeFamily::UNKNOWN_ID
    end

    if @bird.species.nil?
      @species = []
    else
      if @bird.group and @bird.group.composite?
        @species = @bird.group.species
      elsif @bird.foot_type_family.nil?
        ftf = FootTypeFamily.find_by_name('Unknown')
        @species = ftf.species
      else
        @species = @bird.foot_type_family.species
      end

      @species = species_sort(@species)
    end
  end

  def create_bird
    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    @survey = get_session_survey
    raise "Survey is not set" if @survey.id.nil?

    @bird_data = resolve_groups(params[:bird])
    @bird = Bird.new(@bird_data)
    @bird.survey_id = @survey.id

    handle_verification(@bird)

    if @bird.save
      message = "Added Bird of species <i>#{@bird.species.name}</i>"
      redirect_to_entry(message, 4)
    else
      new_bird
      render :action=>:new_bird
    end
  end

  def update_bird
    raise "Bird is not set" if params[:bird].nil?
    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    @bird_data = resolve_groups(params[:bird])
    @bird = Bird.find(@bird_data[:id])

    handle_verification(@bird)

    if @bird.update_attributes(@bird_data)
      message = 'Bird was updated'
      if @submitter.has_role?('verifier')
        if @bird.is_bird == true
          message = "Bird was verified"
        else
          message = "Bird was marked as invalid"
        end
      end
      redirect_to_entry(message, 4)
    else
      edit_bird
      render :action => :edit_bird
    end
  end

  def handle_verification(bird)
    if @submitter.has_role?('verifier')
      if bird.new_record?
        bird_in_db = bird
      else
        bird_in_db = Bird.find(bird.id)
      end

      if bird.verified != true
        bird.original_data = bird_in_db.serialize
        bird.verified = true
      end

      if params[:submit] =~ /verify bird/i
        bird.is_bird = true
      end

      if params[:cancel] =~ /not a bird/i or params[:submit] =~ /not a bird/i
        bird.is_bird = false
      end
    end
  end

  def resolve_groups(bird_data)
    group_id = bird_data[:group_id].to_i
    if group_id < 0
      subgroup_id = -1 * group_id
      group_id = Subgroup.find(subgroup_id).group.id
      bird_data[:group_id] = group_id
      bird_data[:subgroup_id] = subgroup_id
    end
    bird_data
  end

  def add_beach
    render :layout => "site"
  end

  def update_intact_section
    @species_id  = @bird.nil? ? params[:species_id].to_i : @bird.species_id
    if not @species_id.nil?
      update_species_section
    end
  end

  def update_species_section
    @species_id  = @bird.nil? ? params[:species_id].to_i : @bird.species_id
    @family_id   = @bird.nil? ? params[:foot_type_famiy_id].to_i : @bird.foot_type_family_id
    @group_id    = @bird.nil? ? params[:group_id].to_i : @bird.group_id
    @age_id      = @bird.nil? ? params[:age_id].to_i : @bird.age_id

    # intact attributes, find out which length attributes are possible
    @parts_attributes = bird_length_attributes(@bird)

    composite_group = nil

    if not @family_id.nil? and @family_id < 0
      @group_id = -1 * @family_id
      group = Group.find(@group_id)

      @family_id = group.foot_type_family_id
      composite_group = group
    end

    # when editing an existing form, make sure subgroup selections stick
    if !@bird.nil? and !@bird.subgroup_id.nil?
      @subgroup_id = -1 * @bird.subgroup_id
    else
      @subgroup_id = @group_id
    end

    # TODO role allocation through session data, use Role objects
    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    if @submitter.has_role?('verifier')
      @role = 'admin'
    else
      @role = 'volunteer'
    end

    @plumages = Plumage.by_species(@species_id, @role)
    @ages = Age.by_species(@species_id, @role)
    @sex = Species.sex(@species_id, @role)

    @spp_attributes = []
    if @sex.length > 1
      @spp_attributes << 'sex'
    end

    if @plumages.length > 1
      @spp_attributes << 'plumage'
    end

    @groups = []
    if @species_id.to_i == Species::UNKNOWN_ID
      if @family_id.to_i == FootTypeFamily::UNKNOWN_ID || @family_id.to_i == FootTypeFamily::FEET_MISSING_ID
        groups = Group.find(:all, :include => :subgroups).sort {|a,b| a.name <=> b.name}
        @groups = groups.map {|r| [r.name,r.id]}
        @groups.unshift ["Unknown",Group::UNKNOWN_ID]
      elsif not composite_group.blank?
        # we have FTF and group from the composite group, only display subgroups in the 'Group' list
        subgroups = composite_group.subgroups
        if subgroups.length > 0
          subgroups.each do |sg|
            @groups << [sg.name, -1 * sg.id]
          end
          @groups.unshift ["Unknown", -1 * Subgroup::UNKNOWN_ID]
        end
      elsif @family_id.to_i > 0
        family = FootTypeFamily.find(@family_id, :include => [:groups, :subgroups])
        @groups = family.groups.map {|r| [r.name,r.id]}
        group_names = @groups.map {|gn| gn[0]}
        family.groups.each do |g|
          if !g.subgroups.empty?
            g.subgroups.each do |sg|
              if !group_names.include? sg.name
                @groups << [sg.name, -1 * sg.id]
              end
            end
          end
        end
        @groups.unshift ["Unknown",Group::UNKNOWN_ID]
      end
      @groups.unshift []
    end
    # FIXME ADD group info! min & max info w/ format_range to give bounding units of group

    if not @species_id.nil? and @species_id > 0
      species = Species.find(@species_id)

      @bill_range = format_range(species.bill_min,species.bill_max,"mm")
      @tarsus_range = format_range(species.tarsus_min,species.tarsus_max,"mm")
      @wing_range = format_range(species.wing_min,species.wing_max,"cm")
    end
  end

  def bird_length_attributes(bird)
    count = 0
    @parts_attributes = []
    # no map.with_index till ruby 1.9
    Bird::LengthAttributes.values.map do |la, v|
      attr_value = bird.nil? ? params[la] : bird.send(la)
      if attr_value != v
        @parts_attributes << Bird::LengthAttributes.keys[count]
      end
      count += 1
    end
    @parts_attributes
  end

  def format_range(min,max,units = "mm")
    if not min.nil? and min > 0
      ": " + min.to_s + " - " + max.to_s + " " + units
    else
      ""
    end
  end

  def update_species_select
    family_id = params[:foot_type_family_id].to_i
    group = nil

    if family_id < 0
      group_id = -1 * family_id
      group = Group.find(group_id)
      family_id = group.foot_type_family_id
    end
    if family_id == FootTypeFamily::FEET_MISSING_ID || family_id == FootTypeFamily::UNKNOWN_ID
      @species = Species.find(:all)
    else
      if group.nil?
        if family_id > 0
          @species = FootTypeFamily.find(family_id).species
        else
          @species = []
        end
      else
        @species = group.species
      end
    end

    @species = species_sort(@species)
    render :update do |page|
      page.replace_html 'species-div', :partial => "species_select", :object => @species
      page.visual_effect :BlindUp, 'species-attributes-div', {:queue => 'end'}
    end
  end

  def species_sort(species)
    species.sort! {|a,b| a.name <=> b.name }
    unknown = Species.find(Species::UNKNOWN_ID)
    # Move unknown to end
    if species.index(unknown)
      species.slice!(species.index(unknown))
    end
    species.unshift(unknown)
    species
  end

  def check_length
    length_type = params[:length_type]
    length_value = params[:length_value]
    species_id = params[:species_id]

    sp = Species.find(species_id)
    if not sp.nil?
      length_div = length_type.downcase.gsub("_","-") + "-warning-div"

      if sp.length_in_range?(length_type.sub("_length",""), length_value) == false
        render :update do |page|
          page.replace_html length_div, content_tag(:div,"#{length_type.titleize}" \
            + " appears to be out range, confirm this is correct",
            :class => "smallWarningExplanation")
          page.visual_effect :appear, length_div, {:queue => 'end'}
        end
      else
        render :update do |page|
          page.visual_effect :fade, length_div
        end
      end
    end
  end

  def poll_date
    parsed_date = Time.now.smart_parse(params[:date], nil, false, 'date')
    if parsed_date.midnight > Time.now
      date = 'Please choose a past date'
    else
      date = parsed_date.to_s(:survey)
    end

    if date
      render(:update) do |page|
        page.replace_html 'selected_date', date
        page.visual_effect :highlight, 'selected_date', {:duration => 2, :queue => 'end'}
      end
    end
  end

  def poll_time
    start_time, end_time = survey_times(params[:start_time], params[:end_time], Date.today)
    start_time = short_time(start_time)
    end_time   = short_time(end_time)

    time_range = (start_time.empty?) ? "?" : start_time
    time_range += " &ndash; "
    time_range += (end_time.empty?)  ? "?" : end_time

    render(:update) do |page|
      page.replace_html 'selected_time', time_range
      page.visual_effect :highlight, 'selected_time', {:duration => 1, :queue => 'end'}
    end
  end

  def update_beach_information
    @survey = get_session_survey
    if @survey.nil?
      redirect_to :action => :list_data
      return
    end

    if not params[:beach_id].blank?
      guess_travel_times(@survey,params[:beach_id])
      dupe = check_for_duplicate_survey(@survey,params[:beach_id])
      @beach = Beach.find(params[:beach_id])
      render (:update) do |page|
        page.replace_html('travel-data', render(:partial=>"travel_times"))
        page.replace_html('selected_beach', @beach.name)
        page.visual_effect :highlight, 'travel-data', {:duration => 1, :queue => 'end'}
        page.visual_effect :highlight, 'selected_beach', {:duration => 1, :queue => 'end'}
        if not dupe.blank?
          link = link_to "Survey ##{dupe.to_s}", :controller => :survey, :action => :show, :id => dupe
          page.replace_html 'duplicate-survey-warning-div',
            content_tag(:div, "This survey appears to be a duplicate of #{link}.",
              :id => "notice",
              :style => "width: 450px")
          page.visual_effect :appear, 'duplicate-survey-warning-div', {:queue => 'front'}
        else
          page.visual_effect :fade, 'duplicate-survey-warning-div', {:queue => 'front'}
        end
      end
    end
  end

  def list_data
    @volunteer = Volunteer.find(session[:volunteer_id])

    @volunteer_surveys = @volunteer.surveys.find(:all,
                            :conditions => 'is_complete is TRUE',
                            :order => 'survey_date DESC',
                            :include => [{:birds => :species}])

    @bird_count = @volunteer_surveys.map {|s| s.birds.length}.inject(0) {|sum,cnt| sum += cnt.to_i}

    incompletes = @volunteer.surveys.select {|v| !v.is_complete? }

    if incompletes.length > 0
      session[:survey] = incompletes[0]
    end

    @survey = get_session_survey

    render :action => :list_data, :layout => 'data'
  end

  def list_regions
    @volunteer = Volunteer.find(session[:volunteer_id])
    @role = @volunteer.roles[0].name
    @next_step = (@role == 'intern') ? 'intern_region' : 'verification_list_beaches'

    incompletes = @volunteer.surveys.select {|v| !v.is_complete? }

    if incompletes.length > 0
      session[:survey] = incompletes[0]
    end

    @survey = get_session_survey
    @regions = Region.find(:all, :include => [:beaches],
                           :conditions => ['beaches.monitored IS TRUE'],
                           :order => 'regions.name ASC')

    @unreviewed_regions = {}
    @unreviewed_beaches = Beach.find_unverified_surveys_per_beach
    # group the unreviewed beach counts into unreviewed region counts
    @regions.each do |r|
      @unreviewed_regions[r.id] = r.beaches.map { |b|
        @unreviewed_beaches.fetch(b.id, 0)
        }.inject { |sum, x| sum ? sum + x : x }
    end
    render :action => :list_regions, :layout => 'data'
  end

  def intern_region
    @region = Region.find(params[:id])
    @beach_names = {}
    Beach.find(:all).map {|b| @beach_names[b.id] = b.name}

    region_beaches_sql = "SELECT id FROM beaches WHERE region_id = #{@region.id}"
    surveys = Survey.find_by_sql "SELECT id, beach_id, survey_date, verified FROM surveys WHERE " +
                                  "beach_id IN (#{region_beaches_sql}) " +
                                  "ORDER BY survey_date DESC"
    @birds = {}
    @birds_index = {}
    surveys.map {|s| @birds[s.id] = []}
    birds_sql = "SELECT b.* FROM birds b " +
                "LEFT JOIN surveys s ON s.id = b.survey_id " +
                "WHERE s.beach_id IN (#{region_beaches_sql})"
    @birds_list = Bird.connection.execute(birds_sql)

    i = 0
    @birds_list.each do |bird|
      sid = bird['survey_id'].to_i
      bid = bird['id'].to_i
      @birds[sid] << bid
      @birds_index[bid] = i
      i += 1
    end

    @species = {}
    species_list = Species.find(:all)
    species_list.each do |spp|
      @species[spp.id] = spp
    end

    @unreviewed_surveys = []
    @surveys_length = surveys.length

    # SURVEYS can't be VERIFIED until all the birds within them are verified?
    # find verified surveys with unverified birds
    surveys.each do |s|
      verified = s.verified
      if @birds[s.id].select {|id| not @birds_list[@birds_index[id]]['verified'] == 't'}.size > 0
        verified = false
      end
      if not verified
        @birds[s.id].sort! {|a,b| a <=> b}
        @unreviewed_surveys << s
      end
    end
    render :layout => 'data'
  end

  def verification_list_beaches
    @verifier = Volunteer.find(session[:volunteer_id])

    if not @verifier.has_role?('verifier')
      redirect_to :action => :list_data
      return
    end

    @region = Region.find(params[:id], :include => [:beaches])
    @beaches = @region.beaches.sort_by {|b| b.name}
    @unreviewed = Beach.find_unverified_surveys_per_beach

    render :action => :verification_list_beaches, :layout => 'data'
  end

  def verification_beach
    @beach = Beach.find(params[:id], :include => [{:surveys => :birds}])
    @region = @beach.region

    @survey_count = @beach.surveys.length
    @unreviewed_surveys = []
    @reviewed_surveys = []

    # SURVEYS can't be VERIFIED until all the birds within them are verified?
    # find verified surveys with unverified birds
    @beach.surveys.each do |s|
      verified = s.verified
      s.birds.sort! {|a,b| a.id <=> b.id}
      if s.birds.select {|b| not b.verified?}.size > 0
        verified = false
      end

      if not verified
        @unreviewed_surveys << s
      else
        @reviewed_surveys << s
      end
    end
    # unreviewed should be oldest -> newest, reviewed shoult be newest -> oldest
    @unreviewed_surveys.sort! {|a,b| a.survey_date <=> b.survey_date}
    @reviewed_surveys.sort! {|a,b| b.survey_date <=> a.survey_date}
    render :layout => 'data'
  end

  def add_volunteer_to_survey
    new_volunteer = false
    begin
      volunteer = Volunteer.find(params[:volunteer_id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid volunteer " +
                   "#{params[:volunteer_id]}")
      message = "Invalid volunteer"
    else
      @survey = get_session_survey
      if !@survey.all_volunteers.include?(volunteer)
        @survey.add_volunteer(volunteer)
        new_volunteer = true
      end
    end

    render(:update) do |page|
      if new_volunteer
        page.insert_html :bottom, "surveyor_table", :partial => 'survey_volunteer',
          :locals => {:survey_volunteer => volunteer, :action => :remove_volunteer_from_survey }
      end
      page.visual_effect :highlight, "label_#{volunteer.id}", :duration => 2.5,
        :startcolor => "#c6d880", :endcolor => "#ffffff" # 76ee00, c6d880, 4CA446
    end
  end

  def remove_volunteer_from_survey
    @survey = get_session_survey
    begin
      volunteer = Volunteer.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid volunteer " +
                   "#{params[:survey_volunteer][:friend_id]}")
      flash[:notice] = "Invalid volunteer"
      redirect_to :action=>:enter_data, :s=>1
    else
      @survey.remove_volunteer(volunteer)
    end

    render(:update) do |page|
      page.visual_effect :highlight, "label_#{volunteer.id}", :duration => 1,
        :startcolor => "#fbc2c4", :endcolor => "#ffffff"
      page.delay(1.seconds) do
        page.remove "element_#{volunteer.id}"
      end
    end
  end

  # volunteer 'friend' editing, show them their current list of friends,
  # can permanently remove friends from the list
  def remove_volunteer_from_friends
    begin
      @volunteer_friend = VolunteerFriend.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid volunteer friend" +
                   "#{params[:id]}")
      flash[:notice] = "Invalid volunteer friend"
      redirect_to :action=>:enter_data, :s=>1
    else
      logger.error("Removing volunteer friend #{@volunteer_friend.friend_id}")
      @volunteer_friend.destroy
    end

    render(:update) do |page|
      page.visual_effect :highlight, "label_#{@volunteer_friend.id}", :duration => 2,
        :startcolor => "#fbc2c4", :endcolor => "#ffffff"
      page.delay(1.seconds) do
        page.remove "element_#{@volunteer_friend.id}", :queue => 'end'
      end
    end
  end

  def confirm_remove_survey
     @survey = get_session_survey
     @submitter = Volunteer.find_by_id(session[:volunteer_id])

     render :action => :confirm_remove_survey, :layout => 'data'
  end

  def confirm_cancel_bird
    render(:update) do |page|
      page.visual_effect :slide_down, 'cancel-div'
    end
  end

  def confirm_remove_bird
    @bird = Bird.find(params[:id])
    render :action => :confirm_remove_bird, :layout => 'data'
  end

  def remove_survey
    if request.post?
      begin
        @survey = Survey.find(params[:survey][:id])
        @submitter = Volunteer.find_by_id(session[:volunteer_id])
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Cancelled empty survey"
      else
        logger.info("remove_survey: #{@survey.id}")
        # intern and above can remove any survey
        if @submitter.has_role?(["intern", "verifier"])
          remove_survey_parts(@survey)
          logger.info("remove_survey: Survey removed: #{@survey.id}")
          flash[:notice] = "Permanently removed survey ##{@survey.id}"
        # regular users can only remove surveys in progress
        elsif @survey.is_complete? == false
          remove_survey_parts(@survey)
          logger.info("remove_survey: Incomplete Survey removed")
          flash[:notice] = "Cancelled current survey"
        end
      end
      session[:survey] = nil
    end
    redirect_to :action => :index
  end

  # despite having :dependent => :destroy, sometimes the bird records
  # are still not being deleted. Force their deletion here.
  def remove_survey_parts(survey)
    survey.birds.each do |b|
      b.destroy
    end
    survey.destroy
  end

  def remove_bird
    if request.post?
      begin
        @bird = Bird.find(params[:bird][:id])
      rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid bird" +
                   "#{params[:id]}")
        flash[:notice] = "Invalid bird"
        redirect_to :action => :enter_data, :s => 4
      else
        logger.error("Removing bird #{@bird.id}")
        @bird.destroy
      end

      flash[:notice] = "Bird deleted"
      redirect_to :action => :enter_data, :s => 4
    end
  end

  def start_survey
    session[:survey] = nil
    redirect_to :action=>:enter_data
  end

  def edit_survey
    if params.has_key?(:id) and params[:id].to_i > 0
      session[:survey] = Survey.find(params[:id])
      if params.has_key?(:s) and params[:s].to_i > 0
        redirect_to :action => :enter_data, :s => params[:s]
      else
        redirect_to :action => :enter_data
      end
    else
      redirect_to :action => :list_data
    end
  end

  # Beach autocompletion methods
  def auto_complete_for_beach_name
    @name = params[:beach][:name].downcase
    @beaches = Beach.find(:all,
      :conditions => [ 'LOWER(name) LIKE ?',
      '%' + @name + '%' ],
      :limit => 15)
    if @beaches.blank?
      @beaches = []
    end
    render :partial => 'beaches'
  end

  def new_beach
    @volunteer_id = session[:volunteer_id]
    @beach_id = params[:beach][:beach_id]
    @name = params[:beach][:name]

    if @beach_id.blank?
      flash[:notice] = %q|We're sorry, COASST doesn't currently have your beach
                       on file. Contact us with your beach info at:
                       <a href="mailto:#{StaticData::INFO_EMAIL}?subject=COASST%20is%20missing%20my%20beach"
                       >#{StaticData::INFO_EMAIL}</a>|
    elsif VolunteerBeach.beach_exists(@beach_id, @volunteer_id)
      flash[:notice] = "Already have #{@name} as a beach"
    else
      @beach = Beach.find_by_id(@beach_id)
      if !@beach.blank?
        vb = VolunteerBeach.new(:volunteer_id => @volunteer_id,
               :frequency => 1,
               :beach_id => @beach_id)
        vb.save
        flash[:notice] = "Added #{@name} as a beach"
      else
        flash[:notice] = "Couldn't find beach #{@name}"
      end
    end
    redirect_to_entry(nil, 3)
  end

  def beaches_for_lookup
    @beaches = Beach.find(:all)
    render :layout => false
  end

  # manage volunteer friends: add new friends, remove existing ones.
  def manage_friends
    @submitter = Volunteer.find_by_id(session[:volunteer_id])
    if @submitter
      @friends = @submitter.friends.sort_by {|a| a.fullname}
    end

    render :action => :manage_friends, :layout => 'data'
  end

  def new_friend
    volunteer_id = session[:volunteer_id]
    submitter = Volunteer.find(volunteer_id)
    friend_id = params[:volunteer][:volunteer_id].to_i
    friend = Volunteer.find_by_id(friend_id)
    name = params[:volunteer][:fullname]

    if submitter.has_role?(["intern", "verifier"])
      if friend
        survey = get_session_survey
        if survey.data_collectors.include?(friend)
          flash[:notice] = "Already added #{friend.name} to survey"
        else
          survey.add_volunteer(friend)
          flash[:notice] = "Added #{friend.name}"
        end
      end
      redirect_to :controller => 'data', :action => 'enter_data', :s => 1
    else
      if VolunteerFriend.friend_exists(friend_id, volunteer_id)
        flash[:notice] = "Already have #{name} as a friend"
      else
        if friend
          vf = VolunteerFriend.new(
            :volunteer_id => volunteer_id,
            :frequency => 1,
            :friend_id => friend_id
          )
          vf.save
          flash[:notice] = "Added #{name} as a friend"
        else
          flash[:notice] = "Couldn't find volunteer to add as friend"
        end
      end
      redirect_to :action => 'manage_friends'
    end
  end

  def auto_complete_for_volunteer_fullname
    @friends = []
    if not params[:volunteer].nil?
      name = params[:volunteer][:fullname].downcase

      if name =~ / /
        @friends = Volunteer.find(:all,
          :conditions => [ 'LOWER(fullname) LIKE ?',
          name + '%'],
          :limit => 10)
      else
        @friends = Volunteer.find(:all,
          :conditions => [ 'LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?',
          name + '%', name + '%' ],
          :limit => 10)
      end
    end
    render :partial => 'friends'
  end

  def volunteer_role
    role = nil
    role_list = Role.find(:all)

    begin
      volunteer = Volunteer.find(session[:volunteer_id])
      role = 'volunteer'
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid volunteer " +
                   "#{session[:volunteer_id]}")
    end

    role_list.each do |r|
      if volunteer.has_role?(r.name)
        role = r.name
      end
    end

    role
  end

  protected

  def submission_data(step)
    data = {:url => "#{@step - 1}"}
    if @submitter.has_role?('verifier')
      data[:text] = "Verify Step #{step}"
    elsif @survey.is_complete
      data[:text] = "Save Survey"
      data[:url] = "/survey/show/#{@survey.id}"
    else
      data[:text] = "Continue To Step #{step + 1}"
    end
    data
  end

  def short_time(time)
    str = ""
    if !time.nil?
      str = time.strftime("%I:%M %p").downcase
    end
    # trim leading zeroes for presentation purposes
    if str[0,1] == "0"
      str = str.slice(1, str.length)
    end
    str
  end

  def survey_times(start_time,end_time,survey_date)
    start_time = survey_time(start_time,survey_date)
    end_time = survey_time(end_time,survey_date)
    if not start_time.nil? and not end_time.nil?
      # add 12 hours so 6, 7 am become 6, 7 pm
      if end_time.hour < start_time.hour and end_time.hour < 12
        end_time += 12*60*60
      end
    end
    return start_time, end_time
  end

  def survey_time(time, survey_date)
    # Use our modified smart_parse function to parse date and time
    if not time.nil? and not time.empty?
      hour_min = Time.now.smart_parse(time, Time.now.at_beginning_of_year)
      if not hour_min.nil?
        Time.parse("#{survey_date.year}-#{survey_date.month}-#{survey_date.day} #{hour_min.hour}:#{hour_min.min}")
      else
        nil
      end
    else
      nil
    end
  end

  def redirect_to_entry(msg, stage, klass = nil)
    if not msg.nil? and not msg.blank?
      if klass.nil?
        flash[:notice] = msg
      else
        flash[klass] = msg
      end
    end
    redirect_to :action => :enter_data, :s => stage
  end

end
