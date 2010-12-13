require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  
  test "index host" do
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
    assert_equal flash[:notice], "1 Host is being scanned for packages. Please visit the hosts page to view them."
  end
  
  test "edit host" do
    put :edit, {:id => hosts(:fedora).id}
    assert_response :success
  end
  
  test "update host" do
    put :update, {:id => hosts(:fedora).id}, :host => {:name => "updated_fedora"}
    assert_response :redirect
    assert_equal flash[:notice], "Host was successfully updated."
  end
  
  test "scan hosts" do
    get :scan, {:id => hosts(:fedora).id}
    assert_equal flash[:notice], "fedora is being scanned for packages. Please refresh the page to view them."
    assert_redirected_to host_path(hosts(:fedora))
    
    get :scan, {:id => 5}
    assert_equal flash[:notice], "The host you selected doesnt exist!"    
    assert_redirected_to hosts_path
  end
  
end
