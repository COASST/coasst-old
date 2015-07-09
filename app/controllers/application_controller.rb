# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # CVE protection https://groups.google.com/forum/#!topic/rubyonrails-security/61bkgvnSGTQ/discussion
  # 2013.01.08
  ActionController::Base.param_parsers.delete(Mime::XML) 


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  # Session data
  def get_session_updates
    if not session[:updates].blank?
      session[:updates]
    else
      []
    end
  end

  # Enable memory-profiling using Oink
  include Oink::MemoryUsageLogger

  # only enable exception messages on production, to prevent issues with tests
  if ENV["RAILS_ENV"] == 'production'
    include ExceptionNotifiable

    # set from address
    ExceptionNotifier.sender_address = %("COASST Exception" <#{StaticData::EXCEPTION_EMAIL}>)

    # Email these addresses with exceptions from the production service
    ExceptionNotifier.exception_recipients = StaticData::ADMIN_EMAIL
  end

  # export function for tables, requires ActiveScaffold for the table in question
  # from http://www.ibm.com/developerworks/opensource/library/l-activescaffold/
  def export(condition = nil, label = nil)
    require 'fastercsv'
    # TODO add column ordering classes for each 'exportable' table...
    # XXX generalize the approach used in export / volunteers tables to produce views instead
    # find_page is how the List module gets its data. see Actions::List#do_list.
    if not condition.nil?
      records = find_page({:condition => condition}).items
    else
      records = find_page().items
    end

    if records.size == 0
      flash[:notice] = "Sorry! These aren't the birds you're looking for."
      render :action => :index
      return
    end

    model = records[0].class.name
    if label.nil?
      label = model.pluralize
    end

    output_csv = FasterCSV.generate do |csv|
      # Output header to CSV
      csv << records[0].attributes.keys.map {|k| k.titleize}
      records.each do |r|
        csv << r.attributes.values
      end
    end
    send_data output_csv, :type => 'text/csv', :filename => label + '.csv'
  end

  # XXX TODO Fix up this crap, sync it with the methods below which actually use the roles/rights system
  def check_authentication(role = nil)
    volunteer = Volunteer.find_by_id(session[:volunteer_id])

    if volunteer.nil?
      redirect_to :controller => 'volunteer', :action => "login"
      return
    else
      logger.error("volunteer found! `#{volunteer}`; `#{volunteer.id}`; `#{session[:volunteer_id]}`")
    end

    if not role.nil?
      if volunteer.nil?
        logger.info("XXX volunteer now null again...")
        redirect_to :controller => 'volunteer', :action => "login"
      else
        if not volunteer.has_role?(role)
          redirect_to :controller => 'data'
        end
      end
    end
  end

  protected

  def self.active_scaffold_controller_for(klass)
    return RoleDataController if klass == Role
    return RightsDataController if klass == Right
    return VolunteerDataController if klass == Volunteer
    return "#{klass}ScaffoldController".constantize rescue super
  end

  private

  def authenticate
    unless Volunteer.find_by_id(session[:volunteer_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "Please log in"
      redirect_to(:controller => "volunteer", :action => "login")
      return false
    end
  end

  def authorize
    vololunteer = Volunteer.find_by_id(session[:volunteer_id])
    unless has_right?(volunteer)
      flash[:notice] = "You are not authorized to view the page you requested"
      request.env["HTTP_REFERER"] ? (redirect_to :back) : (redirect_to home_url)
    end
  end

  def has_right?(volunteer)
    volunteer.has_right_for?(action_name, self.class.controller_path)
  end

end
