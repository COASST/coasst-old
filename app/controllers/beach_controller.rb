class BeachController < ApplicationController

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :beach do |config|

    actions.exclude :search
    actions.add :live_search

    # link configuration
    delete.link.confirm = "Delete beach?"
    show.link.page = true

    action_links.add 'export', :label => 'Export to CSV', :page => true

    # global columns configuration
    columns[:length].label = "Length (kilometers)"

    # list options
    list.columns = [:name, :code, :description, :city, :region]

    # creation options
    create.link.label = "Add new beach"
    create.columns = [:name, :code, :description, :monitored]

    create.columns.add_subgroup "Location" do |loc_group|
      loc_group.add :state, :region, :county, :city
    end

    create.columns.add_subgroup "Physical" do |phys_group|
      phys_group.add :length, :width, :substrate, :orientation, :geomorphology
    end

    create.columns.add_subgroup "Geographic" do |geo_group|
      geo_group.add :latitude, :longitude, :start_description, :turn_latitude,
        :turn_longitude, :turn_description
    end

    create.columns.add_subgroup "Access" do |access_group|
      access_group.add :access, :ownership, :vehicles_allowed,
        :vehicles_start, :vehicles_end, :dogs_allowed
    end

    # update options
    # TODO any simple way to prevent this duplication?
    #      tried update.columns = create.columns, but no luck
    update.columns = [:name, :code, :description, :monitored]

    update.columns.add_subgroup "Location" do |loc_group|
      loc_group.add :region, :county, :city, :state
    end

    update.columns.add_subgroup "Physical" do |phys_group|
      phys_group.add :length, :width, :substrate, :orientation, :geomorphology
    end

    update.columns.add_subgroup "Geographic" do |geo_group|
      geo_group.add :latitude, :longitude, :start_description, :turn_latitude,
        :turn_longitude, :turn_description
    end

    update.columns.add_subgroup "Access" do |access_group|
      access_group.add :access, :ownership, :vehicles_allowed,
        :vehicles_start, :vehicles_end, :dogs_allowed
    end

    # don't allow manipulation of these tables, just provide select list
    [:region, :state, :county].each do |select|
      columns[select].form_ui = :select
    end

    # Minimum fields neccessary for a valid beach
    [:code, :name, :description, :region, :length, :width, :latitude, :longitude].each do |req|
      columns[req].required = true
    end

  end

  def show
    beach_id = params[:id].to_i
    @beach = Beach.find(beach_id,:include=>[:region,:state])
    # conditions = "beach_id = ? AND (birds.refound IS FALSE OR birds.refound IS NULL)"
    # scw: original logic above; asked to include all birds in this listing logic (Mar 2013)
    conditions = "beach_id = ?"
    condition_vars = [beach_id]
    surveys = Survey.find(:all,:conditions=>[conditions] + condition_vars,:include=>{:birds=>:species})
    #logger.debug(surveys)

    @birds_by_year = {}
    @surveys_by_year = {}
    for s in surveys
      #logger.debug(s)
      if not @birds_by_year.has_key? s.survey_date.year
        @birds_by_year[s.survey_date.year] = 0
      end
      if not @surveys_by_year.has_key? s.survey_date.year
        @surveys_by_year[s.survey_date.year] = 0
      end
      @birds_by_year[s.survey_date.year] += s.birds.length
      @surveys_by_year[s.survey_date.year] += 1
    end

    @years = @surveys_by_year.keys.sort.reverse

    @by_species = {}
    for s in surveys
      for b in s.birds
        if not @by_species.has_key? b.species
          @by_species[b.species] = 0
        end
        @by_species[b.species] += 1
      end
    end

    @species = @by_species.keys.sort {|a,b| @by_species[b] <=> @by_species[a]}

    if !Beach::LocationInvalid.include? @beach.location_notes and !@beach.latitude.blank?
      @map = get_map(@beach.latitude, @beach.longitude, @beach.name)
    end
    render :layout => 'plain'
  end

  def get_map(lat = nil, long = nil, name = "Test Location")
    if lat and long
      map = GMap.new("map")
      map.control_init(:small_map => true)
      map.set_map_type_init(GMapType::G_HYBRID_MAP)
      map.interface_init(:continuous_zoom => true, :scroll_wheel_zoom => true, :prevent_pagescroll => true)
      map.center_zoom_init([lat,long],8)
      map.overlay_init(GMarker.new([lat,long],:title => name))
      map
    end
  end

end
