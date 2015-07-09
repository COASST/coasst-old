module MigrantSpeciesHelper

  def status_form_column(record, field_name)
    radio_btns = []
    MigrantSpecies::Status.each do |display, value|
      if record.status == value
        checked = true
      else
        checked = false
      end 
      radio_btns.push("#{radio_button_tag field_name, value, checked} #{display}")
    end
    radio_btns.join("<br />")
  end

end
