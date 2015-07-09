module RegionHelper
  #include ActionView::Helpers::UrlHelper
  
  def beach_overlay(b, survey_count)
    "<div>
      <h3>#{link_to(b.name,{:action=>:show,:controller=>:beach,:id=>b.id})}</h3>
      <p class=\"small map\" >#{survey_count} surveys</p>
     </div>"
  end
  
  def region_overlay(r)
    "<div>
      <h3>#{link_to(r.name,{:action=>:show,:controller=>:region,:id=>r.id})}</h3>
      <p class=\"small map\">#{r.beaches.count} beaches</p>
     </div>"
    #"<div>"+link_to(r.name,{:action=>:show,:controller=>:region,:id=>r.id})+"</div>"
  end
  
  def beaches_with_coords(beaches)
    beaches.select { |b| !b.latitude.nil? and !b.longitude.nil? \
      and !Beach::LocationInvalid.include? b.location_notes and b.monitored? }
  end
  
  def points(coords)
    coords.map {|b| [b.latitude.to_f, b.longitude.to_f]}  
  end
  
  def get_bounding_box(coords,padding=0.25)
    min_lat = nil
    max_lat = nil
    min_lng = nil
    max_lng = nil
    if coords.length > 0 
      coords.each do |lat, lng|
        min_lat = lat if min_lat.nil? or lat < min_lat
        max_lat = lat if max_lat.nil? or lat > max_lat
        # longitude can be large positive numbers for AK regions,
        # convert these into their negative postion for the bbox
        lng = lng - 360 if lng > 0
        min_lng = lng if min_lng.nil? or lng < min_lng
        max_lng = lng if max_lng.nil? or lng > max_lng
      end
      #padding
      lat_diff = max_lat-min_lat
      max_lat += lat_diff*padding
      min_lat -= lat_diff*padding
      lng_diff = max_lng-min_lng
      max_lng += lng_diff*padding
      min_lng -= lng_diff*padding
    end
    [[min_lat,min_lng],[max_lat,max_lng]] 
  end
end
