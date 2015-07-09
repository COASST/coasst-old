require File.dirname(__FILE__) + '/../test_helper'
require 'volunteer_controller'

# Re-raise errors caught by the controller.
class VolunteerController; def rescue_action(e) raise e end; end

class VolunteerControllerTest < Test::Unit::TestCase

  fixtures :states, :volunteers
  
  def setup
    @controller = VolunteerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @emails = ActionMailer::Base.deliveries
    @emails.clear
  end

  def test_forgot_password
    get(:forgot_password, :email => volunteers(:billy_m_blanks).email)
    assert_redirected_to(:action => :login)
    assert_equal(1, @emails.size)
    email = @emails.first
    assert_equal("COASST.org: Reset Password", email.subject)
    assert_equal("billyblanks@bugmenot.com", email.to[0])
    assert_match(/Dear Billy M Blanks/, email.body)
  end
  
  def test_login
    billy = volunteers(:billy_m_blanks)
    post :login, :email => billy.email, :password => 'test123'
    assert_redirected_to :action => "index"
    assert_equal billy.id, session[:volunteer_id]
  end
end
