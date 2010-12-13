require 'test_helper'

class PackagesControllerTest < ActionController::TestCase

  test "index package" do
    get :index
    assert_response :success
    assert_not_nil assigns[:packages]
  end
  
  test "show package" do
    get :show, {:id => packages(:apache).id}
    assert_response :success
    assert_not_nil assigns(:package)
    
    get :show, {:id => 12}
    assert_equal flash[:notice], "The package you selected doesnt exist!"
    assert_redirected_to packages_path
  end
  
  test "create package" do
    assert_difference 'Package.count' do
      post :create, :package => {:name => 'another_package'}
    end
    assert_redirected_to package_path(assigns(:package))
    assert_equal flash[:notice], "Package successfully created."
  end

=begin
  test "edit package" do
    put :edit, {:id => packages(:apache).id}
    assert_response :success
  end
  
  test "update package" do
    put :update, {:id => packages(:apache).id}, :host => {:name => "updated_apache"}
    assert_response :redirect
    assert_equal flash[:notice], "Package was successfully updated."
  end
=end
  
end
