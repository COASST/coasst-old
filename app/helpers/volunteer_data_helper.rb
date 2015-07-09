module VolunteerDataHelper

  # formatting for list
  def phone_column(record)
    Volunteer.phone_formatted(record.phone, record.extension)
  end

  # formatting for editing
  # inherits from other helpers, e.g. VolunteerHelper
  def state_form_column(record, field_name)
    list = State.all_states.collect {|s| [s.name, s.id]}
    list.unshift(["- select -", ""])
    select_tag field_name, options_for_select(list, selected = elem_select(record.state))
  end

  def contact_method_form_column(record, field_name)
    select_tag field_name, options_for_select(Volunteer::ContactMethod.sort, selected = record.contact_method)
  end

  def gender_form_column(record, field_name)
    select_tag field_name, options_for_select(Volunteer::Gender.sort, selected = record.gender)
  end

  def find_us_category_form_column(record, field_name)
    select_tag field_name, options_for_select(Volunteer::FindUsCategory, selected = record.find_us_category)
  end

  def birding_experience_form_column(record, field_name)
    select_tag field_name, options_for_select(Volunteer::BirdingExperience, selected = record.birding_experience)
  end

  def deposit_type_form_column(record, field_name)
    select_tag field_name, options_for_select(Volunteer::DepositType, selected = record.deposit_type)
  end

  def deposit_return_type_form_column(record, field_name)
    select_tag field_name, options_for_select(Volunteer::DepositReturnType, selected  = record.deposit_return_type)
  end

  def kit_type_form_column(record, field_name)
    select_tag field_name, options_for_select(Volunteer::KitType, selected = record.kit_type)
  end

  def volunteer_comments_form_column(record, field_name)
    text_area :record, :volunteer_comments, :cols => 55, :rows => 4, :value => record.volunteer_comments
  end

end
