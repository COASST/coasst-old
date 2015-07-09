require File.dirname(__FILE__) + '/../test_helper'
require 'data_controller'

# Re-raise errors caught by the controller.
class DataController; def rescue_action(e) raise e end; end

class DataControllerTest < Test::Unit::TestCase
  def setup
    @controller = DataController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_redirected_to :login
    assert_response :success

  end
end
