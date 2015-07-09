class CountyController < ApplicationController
  include RegionHelper

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :county do |config|
    config.columns = [:name, :state, :division]
    config.actions.exclude :delete

    # list configuration
    config.list.per_page = 100
    config.list.sorting = { :name => :asc }

    # attributes used in create & update
    base_columns = [:name, :state, :division]

    # creation options
    create.link.label = "Add new county"
    create.columns = base_columns

    # update options
    update.columns = base_columns

    config.columns[:state].form_ui = :select
  end

  def show
    @county = County.find(params[:id])
    @beaches = @county.beaches
    @type = County::Types.to_h[@county.division]

    @beaches.each do |b|
      if !b.monitored
        # nuke the unmonitored beach from the view
        @beaches.delete(b)
      end
    end
    @beaches_with_coords  = beaches_with_coords(@beaches)

    @points = points(@beaches_with_coords)
    @bbox = get_bounding_box(@points)
    @map = get_map(@bbox)
    render :layout => 'plain'
  end

  def get_map(bbox)
    if bbox.empty?
      nil
    else
      map = GMap.new("map")
      map.control_init(:small_map => true)
      map.set_map_type_init(GMapType::G_HYBRID_MAP)
      map.interface_init(:continuous_zoom => true, :scroll_wheel_zoom => true, :prevent_pagescroll => true)
      map.center_zoom_on_bounds_init(bbox)
      map
    end
  end

end
