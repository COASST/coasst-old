module SurveyHelper
  def list_volunteers(volunteer_list)
    names = {}
    for v in volunteer_list
      if names[v.id]
        names[v.id] << v
      else
        names[v.id] = v
      end
    end
    name_links = []
    names.each do |id,volunteer|
      full_name = volunteer.fullname
      # FIXME: re-enable this link?
      link = ""
      link += full_name
      #link += link_to(full_name, :controller=>:volunteer, :action=>:show, :id=>id)
      name_links << link
    end
    #name_links.join(", ")
    name_links
  end
  
end
