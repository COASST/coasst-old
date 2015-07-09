class SiteController < ApplicationController
  layout 'site'

  def index
    vol = session[:volunteer_id]
    if not vol.blank?
      v = Volunteer.find(vol)
      if not v.blank?
        redirect_to :controller => :data
      end
    else
      @total_volunteers = Volunteer.count
    end
  end

end
