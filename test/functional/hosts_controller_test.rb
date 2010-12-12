require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  
  test "index" do
    get :index
    assert_response :success
    assert_not_nil assigns[:hosts]
  end
  
  test "show host" do
    get :show, {:id => hosts(:fedora).id}
    assert_response :success
    assert_not_nil assigns(:host)
    
    get :show, {:id => 12}
    assert_equal flash[:notice], "The host you selected doesnt exist!"
    assert_redirected_to hosts_path
  end
  
  test "create host" do
    assert_difference 'Host.count' do
      post :create, :host => {:name => 'another_fedora_box'}
    end
    assert_redirected_to hosts_path
    assert_equal flash[:notice], "1 Hosts are being scanned for packages. Please visit the hosts page to view them."
  end
  
  
end
