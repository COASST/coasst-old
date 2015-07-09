class RegionController < ApplicationController

  # force activerecord object counting
  include Oink::InstanceTypeCounter

  include RegionHelper

  layout 'plain'

  def choose_layout
    if params[:plain]
      'plain'
    else
      'site'
    end
  end

  def index
    show_all
    render :action => 'show_all'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
  :redirect_to => { :action => :list }

  def list
    @regions = Region.paginate :page => params[:page], :per_page => 20
  end

  def show_all
    @regions = Region.find(:all, :include => :beaches)

    all_points = []
    @longitude = {}
    @latitude = {}
    @points = []
    @states = State.current_states

    @regions.each do |r|
      @beaches_with_coords = beaches_with_coords(r.beaches)
      points = points(@beaches_with_coords)

      if points.length > 0
        bbox = get_bounding_box(points,0.0)
        all_points << bbox[0]
        all_points << bbox[1]
        midlng = (bbox[0][1] + bbox[1][1])/2.0
        midlat = (bbox[0][0] + bbox[1][0])/2.0
        @longitude[r.id] = midlng
        @latitude[r.id] = midlat
        @points << [midlat,midlng]
      end
    end
    @bbox = get_bounding_box(all_points,0.0)
    @map = get_map(@bbox)
  end

  def show
    @region = Region.find(params[:id], :include => {:beaches => [:county]},
                :order => 'counties.name ASC, beaches.name ASC')
    @beaches = @region.beaches
    #@survey_counts = Beaches.find_by_sql("SELECT beach_id, COUNT(*) FROM beach_id IN (?) GROUP BY beach_id, project", @beaches.collect {|b| b.id}])

    @counties = []
    @county_divisions = {}
    County::Types.map {|t| @county_divisions[t[1]] = t[0]}
    @beaches_by_county = {}
    @beach_survey_count = {}
    @beaches_valid = []
    @beaches_invalid_loc = []
    @beaches_coasst = []

    # Check if the beach has any COASST surveys; some beaches are
    # only used in special projects and shouldn't be displayed

    # optimize this by doing the grouping directly in SQL, and avoid the survey objects
    beach_by_project = Beach.find_by_sql(["SELECT beach_id, project, COUNT(*) FROM surveys WHERE beach_id IN (?) AND project = 'COASST' GROUP BY beach_id, project", @beaches.collect {|b| b.id}])
    @beaches_coasst = beach_by_project.collect {|b| b.beach_id.to_i}
    @beach_survey_count = {}
    beach_by_project.each do |b|
      @beach_survey_count[b.beach_id.to_i] = b.count.to_i
    end

    @beaches.each do |b|
      # ignore non-COASST and unmonitored beaches
      if @beaches_coasst.include? b.id and b.monitored
        @beaches_valid.push(b)

        # Beaches without county data, set to 'Unknown' county
        if not b.county
          b.county = County.find_by_name('Unknown')
        end

        # map the beach by county
        if @beaches_by_county.has_key?(b.county)
          @beaches_by_county[b.county] << b
        else
          @beaches_by_county[b.county] = [b]
          @counties << b.county
        end
      end
      # Beaches with location notes should be separated out
      if Beach::LocationInvalid.include? b.location_notes
        @beaches_invalid_loc.push(b)
      end
    end

    # Check if the beaches have been surveyed in the last 6 months
    @inactive_beaches = []
    beach_activity = Survey.find_by_sql(["SELECT AGE(MAX(survey_date)) <= '6 months'::interval AS active, beach_id FROM surveys WHERE beach_id IN (?) GROUP BY beach_id", @beaches.collect {|b| b.id}])
    beach_activity.each do |b|
      if b.active == 'f'
        @inactive_beaches.push(b.beach_id)
      end
    end

    @beaches_with_coords = beaches_with_coords(@beaches_valid)

    @points = points(@beaches_with_coords)
    @bbox = get_bounding_box(@points)
    @map = get_map(@bbox)
  end

  def new
    @region = Region.new
  end

  def create
    @region = Region.new(params[:region])
    if @region.save
      flash[:notice] = 'Region was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @region = Region.find(params[:id])
  end

  def update
    @region = Region.find(params[:id])
    if @region.update_attributes(params[:region])
      flash[:notice] = 'Region was successfully updated.'
      redirect_to :action => 'show', :id => @region
    else
      render :action => 'edit'
    end
  end

  def destroy
    #Region.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def get_map(bbox)
    if bbox.empty?
      nil
    else
      map = GMap.new("map")
      map.control_init(:large_map => true, :map_type => 'G_SATELLITE_MAP')
      map.set_map_type_init(GMapType::G_HYBRID_MAP)
      map.interface_init(:continuous_zoom => true, :scroll_wheel_zoom => true, :prevent_pagescroll => true)
      map.center_zoom_on_bounds_init(bbox)
      map
    end
  end
end
