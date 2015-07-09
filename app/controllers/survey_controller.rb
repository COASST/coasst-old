class SurveyController < ApplicationController
  layout "site"

  def index
  end

  before_filter :check_authentication

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def show
    @survey = Survey.find(params[:id],:include=>{:birds=>:plumage})
    @birds = @survey.birds.sort {|a, b| a.id <=> b.id}
    # TODO: fix this dumb workaround by having 'survey.tracks_present' actually work
    @tracks = []
    @survey.survey_tracks.each do |tr|
      if tr.has_data?
        @tracks << tr
      end
    end

    @data_collectors = []
    @survey.survey_volunteers.each do |sv|
      if sv.role == 'data collector'
        v = Volunteer.find_by_id(sv.volunteer_id)
        @data_collectors << {:volunteer => v, :travel_time => sv.travel_time}
      end
    end

    @display_buttons = false
    @can_edit = false

    if not session[:volunteer_id].blank?
      @volunteer = @survey.volunteers.find_by_id(session[:volunteer_id])
      @v2 = Volunteer.find_by_id(session[:volunteer_id])

      if not @survey.verified? or @v2.has_role?('verifier')
        @can_edit = true
      end

      if @volunteer == @v2
        @display_buttons = true
      end
    end

    render :layout => 'data'
  end

  def survey_completed
    @survey = Survey.find(params[:id], :include => {:birds => :plumage})

    # send a notification message to the coasst account with information about this survey and any updates
    @updates = get_session_updates
    if not @updates.empty?
      VolunteerNotifier.deliver_volunteer_added(@survey, @updates)
      session[:updates] = []
    end
    render :layout => 'data'
  end
end
