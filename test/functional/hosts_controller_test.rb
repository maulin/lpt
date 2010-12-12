require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  
  test "index" do
    get :index
    assert_response :success
  end
  
end
