require File.dirname(__FILE__) + '/../test_helper'
require 'beach_controller'

# Re-raise errors caught by the controller.
class BeachController; def rescue_action(e) raise e end; end

class BeachControllerTest < Test::Unit::TestCase
  fixtures :beaches

  def setup
    @controller = BeachController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = beaches(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:beaches)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:beach)
    assert assigns(:beach).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:beach)
  end

  def test_create
    num_beaches = Beach.count

    post :create, :beach => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_beaches + 1, Beach.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:beach)
    assert assigns(:beach).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Beach.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Beach.find(@first_id)
    }
  end
end
