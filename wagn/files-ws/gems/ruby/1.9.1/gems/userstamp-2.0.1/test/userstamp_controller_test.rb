require 'test/helper'

class PostsControllerTest < ActionController::TestCase
  def setup
    reset_to_defaults
    @controller   = PostsController.new
    @request      = ActionController::TestRequest.new
    @response     = ActionController::TestResponse.new
  end

  def test_update_post
    @request.session  = {:person_id => @delynn.id}
    post :update, :id => @first_post.id, :post => {:title => 'Different'}
    assert_response :success
    assert_equal 'Different', assigns["post"].title
    assert_equal @delynn, assigns["post"].updater
  end

  def test_update_with_multiple_requests
    @request.session = {:person_id => @delynn.id}
    get :edit, :id => @first_post.id
    assert_response :success

    simulate_second_request    

    post :update, :id => @first_post.id, :post => {:title => 'Different'}
    assert_response :success
    assert_equal    'Different', assigns["post"].title
    assert_equal    @delynn, assigns["post"].updater
  end
  
  def simulate_second_request
    @second_controller  = PostsController.new
    @second_request     = ActionController::TestRequest.new
    @second_response    = ActionController::TestResponse.new
    @second_response.session = {:person_id => @nicole.id}

    @second_request.env['REQUEST_METHOD'] = "POST"
    @second_request.action = 'update'

    parameters = {:id => @first_post.id, :post => {:title => 'Different Second'}}
    @second_request.assign_parameters(@second_controller.class.controller_path, 'update', parameters)
    @second_request.session = ActionController::TestSession.new(@second_response.session)
    
    options = @second_controller.send(:rewrite_options, parameters)
    options.update(:only_path => true, :action => 'update')
    
    url = ActionController::UrlRewriter.new(@second_request, parameters)
    @second_request.set_REQUEST_URI(url.rewrite(options))
    @second_controller.process(@second_request, @second_response)
    
    assert_equal @nicole, @second_response.template.instance_variable_get("@post").updater
  end
end

class UsersControllerTest < ActionController::TestCase
  def setup
    reset_to_defaults
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_update_user
    @request.session  = {:user_id => @hera.id}
    post :update, :id => @hera.id, :user => {:name => 'Different'}
    assert_response :success
    assert_equal    'Different', assigns["user"].name
    assert_equal    @hera, assigns["user"].updater
  end
  
  def test_update_with_multiple_requests
    @request.session  = {:user_id => @hera.id}
    get :edit, :id =>  @hera.id
    assert_response :success
    
    simulate_second_request
  end

  def simulate_second_request
    @second_controller  = UsersController.new
    @second_request     = ActionController::TestRequest.new
    @second_response    = ActionController::TestResponse.new
    @second_response.session = {:user_id => @zeus.id}

    @second_request.env['REQUEST_METHOD'] = "POST"
    @second_request.action = 'update'

    parameters = {:id => @hera.id, :user => {:name => 'Different Second'}}
    @second_request.assign_parameters(@second_controller.class.controller_path, 'update', parameters)
    
    @second_request.session = ActionController::TestSession.new(@second_response.session)
    
    options = @second_controller.send(:rewrite_options, parameters)
    options.update(:only_path => true, :action => 'update')
    
    url = ActionController::UrlRewriter.new(@second_request, parameters)
    @second_request.set_REQUEST_URI(url.rewrite(options))
    @second_controller.process(@second_request, @second_response)
    
    assert_equal @zeus, @second_response.template.instance_variable_get("@user").updater
  end
end