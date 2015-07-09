module BeachHelper

  def description_form_column(record, field_name)
    text_area :record, :description, :cols => 50, :rows => 6, :value => record.description
  end

  def start_description_form_column(record, field_name)
    text_area :record, :start_description, :cols => 50, :rows => 6, :value => record.start_description
  end

  def turn_description_form_column(record, field_name)
    text_area :record, :turn_description, :cols => 50, :rows => 6, :value => record.turn_description 
  end

  def access_form_column(record, field_name)
    # use lookup list from list in access model
    select_tag field_name, options_for_select(Beach::Access.sort, selected = record.access)
  end

  def ownership_form_column(record, field_name)
    select_tag field_name, options_for_select(Beach::Ownership.sort, selected = record.ownership)
  end

  def substrate_form_column(record, field_name)
    select_tag field_name, options_for_select(Beach::Substrate.sort, selected = record.substrate)
  end

  def geomorphology_form_column(record, field_name)
    select_tag field_name, options_for_select(Beach::Geomorphology.sort, selected = record.geomorphology)
  end

  def orientation_form_column(record, field_name)
    select_tag field_name, options_for_select(Beach::Orientation, selected = record.orientation)
  end

  def width_form_column(record, field_name)
    select_tag field_name, options_for_select(Beach::Width, selected = record.width)
  end

  def region_form_column(record, field_name)
    select_tag field_name, options_for_select(Region.find(:all).collect {|r| [r.name, r.id]}, 
      selected = elem_select(record.region))
  end

  def vehicles_start_form_column(record, field_name)
    select_tag field_name, options_for_select(date_map, selected = record.vehicles_start)
  end

  def vehicles_end_form_column(record, field_name)
    select_tag field_name, options_for_select(date_map, selected = record.vehicles_end)
  end

  def date_map
    map = [["", nil]]
    Date::MONTHNAMES[1..12].each_with_index {|d, i| map << [d, i+1]}
    map
  end

end
