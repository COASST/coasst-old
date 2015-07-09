class VolunteerController < ApplicationController

  layout 'site'

  before_filter :check_authentication, :only => [:show, :add_volunteer, :add_volunteer_submit]

  def login
    session[:volunteer_id] = nil
    if request.post?
      volunteer = Volunteer.authenticate(params[:email], params[:password])
      if volunteer
        session[:volunteer_id] = volunteer.id
        # Often email addresses have multiple individuals associated,
        # if this is the case, let them choose the volunteer after login
        if volunteer.multiple_users?
          redirect_to(:action => 'choose_volunteer')
        else
          flash[:notice] = "Welcome, #{volunteer.name.to_s}"
          redirect_to(:controller => "data", :action => "index")
        end
      else
        vol = Volunteer.primary_user(params[:email])
        if not vol.nil? and not vol.has_account?
          flash[:notice] = "Upgrade this account"
          redirect_to(:action => :activate_volunteer, :id => vol.id)
        else
          flash[:notice] = "Invalid volunteer/password combination"
        end
      end
    end
  end

  def add_volunteer
    @require_email = false
    render :layout => 'data'
  end

  def add_volunteer_submit
    @volunteer = Volunteer.new(params[:volunteer])
    @submitter = Volunteer.find_by_id(session[:volunteer_id])

    if @volunteer.valid? and request.post?
      if @volunteer.save
        if add_volunteer_as_friend(@volunteer)
          flash[:notice] = "Added new volunteer #{@volunteer.name.to_s}"

          # push this information into the updates information, which will be flushed on submission
          @update = "Volunteer #{@submitter.fullname} has added a new volunteer " +
                    "to the site: #{@volunteer.fullname}"
          @updates = get_session_updates
          @updates.push(@update)
          session[:updates] = @updates
          redirect_to :controller => 'data', :action => 'enter_data', :s => 1
        else
          flash[:notice] = "Failed to add new volunteer, couldn't save as friend"
        end
      else
        @volunteer.destroy
        flash[:notice] = "Failed to add volunteer (saving failed)"
      end
    else
      if @volunteer.errors.on(:fullname)
        flash[:notice] = "A volunteer already exists with the name " +
                         "'#{@volunteer.fullname}'. Please add them below."

        if @submitter.has_role?(['intern', 'verifier'])
          redirect_to :controller => :data, :action => :enter_data, :s => 1 and return
        else
          redirect_to :controller => :data, :action => :manage_friends and return
        end
      else
        flash[:notice] = "errors detected"
        render :action => :add_volunteer
      end
    end
  end

  def add_volunteer_as_friend(volunteer)
    vf = VolunteerFriend.new(:volunteer_id => session[:volunteer_id],
             :frequency => 1,
             :friend_id => volunteer.id
    )
    if vf.save
      true
    else
      false
    end
  end

  def friends_for_lookup
    @volunteers = Volunteer.find(:all)
    render :layout => false
  end

  # register volunteer: make a new account for a volunteer, from scratch
  def register_volunteer_submit
    account_data = params[:volunteer]
    account_data[:has_account] = true

    @volunteer = Volunteer.new(account_data)
    if request.post? and @volunteer.valid?
      if @volunteer.save
        flash[:notice] = 'Your account was successfully created! Please login below.'
        redirect_to :controller => :volunteer, :action => 'login' and return
      else
        flash[:notice] = "Failed to register volunteer (could't save)"
      end
    end
    render :action => :register_volunteer
  end

  def choose_volunteer
    @default_volunteer = Volunteer.find(session[:volunteer_id])
    if !@default_volunteer.nil?
      @volunteers = Volunteer.volunteers_with_email(@default_volunteer.email)
    else
      flash[:notice] = "Unable to locate volunteer"
    end

    if request.post?
      volunteer = Volunteer.find_by_id(params[:volunteer][:primary])
      if volunteer
        session[:volunteer_id] = volunteer.id
        flash[:notice] = "Welcome, #{volunteer.name.to_s}"
        redirect_to(:controller => "data", :action => "index")
      else
        flash[:notice] = "Unable to locate volunteer"
      end
    end
  end

  def detect_volunteer
    if not params[:volunteer].nil?
      @volunteer_id = params[:volunteer][:id]
    else
      @volunteer_id = (params[:id]) ? params[:id] : session[:volunteer_id]
    end

    @volunteer = Volunteer.find(@volunteer_id)

    if not @volunteer
      flash[:notice] = "No volunteer found.  Please log in."
      redirect_to :controller => 'data', :action => 'index' and return
    end

    @volunteer
  end

  def activate_volunteer
    flash[:notice] = 'Please create a password for your account.'

    @volunteer = detect_volunteer

    render :layout => 'data'
  end

  def edit_volunteer

    @volunteer = detect_volunteer
    if params[:volunteer]
      edit_volunteer_submit
    else
      render :layout => 'data'
    end
  end

  def activate_volunteer_submit
    account_data = params[:volunteer]
    @volunteer = Volunteer.find(account_data[:id])

    # check the email used for authenticated roles, deny in this case
    if not @volunteer.email.blank?
      if @volunteer && @volunteer.has_role?(['verifier', 'intern'])
        @volunteer.errors.add_to_base("Can't create an account for this email address, use <tt>#{StaticData::INFO_EMAIL}</tt> if you don't have access to email.")
      end
    end

    # check the user has set a password successfully
    if account_data[:password].blank? or account_data[:password] != account_data[:password_confirmation]
      @volunteer.errors.add_to_base("Password required, and confirmation field must match")
    end

    if @volunteer.update_attributes(account_data)
      flash[:notice] = 'Your account was successfully upgraded! Please login below.'
      redirect_to :action => 'login' and return
    end
  end

  def edit_volunteer_submit
    account_data = params[:volunteer]
    @volunteer = Volunteer.find(account_data[:id])

    if account_data[:email].blank?
      @volunteer.errors.add_to_base("Email address is required.")
    end

    if @volunteer.errors.count == 0
      if @volunteer.update_attributes(account_data)
        flash[:notice] = 'Account information successfully updated.'
      else
        flash[:notice] = 'Failed to update volunteer information'
        logger.error "Volunteer couldn't be written: #{@volunteer}"
      end
    end

    render :layout => 'data', :action => 'edit_volunteer', :id => account_data[:id]
  end

  def update_volunteer
    @volunteer = Volunteer.find(session[:volunteer_id])
    logger.error("Volunteer: #{@volunteer.to_yaml}")
    logger.error("Params: #{params[:volunteer].to_yaml}")
    if @volunteer.update_attributes(params[:volunteer])
      flash[:notice] = 'Your information was successfully updated.'
      redirect_to :controller => 'data', :action => 'index'
    end
  end

  def upgrade_account
    email = params[:email]

    # check that the email on file seems semi-legit
    if email.nil? or !email.include? '@'
      flash[:notice] = "No address specified"
      redirect_to(:action => :login)
      return
    end

    vol = Volunteer.primary_user(email)
    if vol.nil?
      flash[:notice] = "We can't find your email address! Please contact the COASST office at <a mailto=\"#{StaticData::INFO_EMAIL}\">#{StaticData::INFO_EMAIL}</a> or #{StaticData::INFO_PHONE} and we will make sure you are entered."
      redirect_to(:action => :login)
    else
      if vol.has_account?
        flash[:notice] = "An active account is already present, please log in"
        redirect_to(:action => :login, :email => vol.email)
      else
        flash[:notice] = "Upgrade this account"
        redirect_to(:action => :activate_volunteer, :id => vol.id)
      end
    end
  end

  # forgot password routine from:
  # http://onrails.org/articles/2007/05/09/forgot-password
  def forgot_password
    email = params[:email]

    vol = Volunteer.primary_user(email)
    if (vol && vol.has_account?)
      vol.reset_password_code_until = 1.day.from_now
      vol.reset_password_code = Digest::SHA1.hexdigest( "#{vol.email}#{Time.now.to_s.split(//).sort_by {rand}.join}" )
      vol.save!
      VolunteerNotifier.deliver_forgot_password(vol)
      flash[:notice] = "Reset password link emailed to #{vol.email}."
      redirect_to(:action => :login)
    else
      if vol.nil?
        if email.blank?
          notice = "Please enter an email address"
        else
          notice = "Volunteer not found: #{email}"
        end
      else
        notice = "It looks like this account needs to be upgraded: " +
          "<a href=\"/volunteer/upgrade?email=#{email}\">Upgrade now</a>"
      end
      flash[:notice] = notice
      redirect_to(:action => :forgot)
    end
  end

  def change_password
    # accept the initial password reset request, push through a form for them to create a new one
    if params[:volunteer_id]
      vol = Volunteer.find(params[:volunteer_id])
    else
      vol = Volunteer.find_by_reset_password_code(params[:id])
    end

    if vol && vol.has_account && vol.reset_password_code_until && Time.now < vol.reset_password_code_until
      @volunteer = vol
    else
      flash[:notice] = "Password reset code has expired."
      redirect_to :action => :login
    end
  end

  def reset_password
    account_data = params[:volunteer]
    @volunteer = Volunteer.find(account_data[:id])
    if @volunteer
      if account_data[:password].blank? or account_data[:password] != account_data[:password_confirmation]
        # can't use model errors as we lack a session (unauthenticated)
        flash[:error] = "Password required, and confirmation field must match"
      else
        if @volunteer.update_attributes(account_data)
          flash[:notice] = "Password successfully reset"
          redirect_to :action => :login and return
        else
          flash[:error] = "Failed to update volunteer information"
        end
      end
    else
      flash[:notice] = "No matching volunteer found"
    end
    redirect_to :action => :change_password,
      :id => @volunteer.reset_password_code,
      :volunteer_id => @volunteer.id
  end

  def list
  end

  def logout
    session[:volunteer_id] = nil
    session[:survey] = nil

    flash[:notice] = "Logged out of COASST, thanks for stopping by."
    redirect_to(:action => "login")
  end

  def index
    @total_volunteers = Volunteer.count
  end
end
