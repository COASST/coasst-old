module CountyHelper

  def division_form_column(record, field_name)
    select_tag field_name, options_for_select(County::Types.sort, selected = record.division)
  end

end
