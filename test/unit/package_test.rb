require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  
  test "package name should be unique" do
    p = Package.new(:name => "apache")
    assert !p.valid?
    assert_equal "has already been taken", p.errors[:name].to_s
  end
  
  test "package name validation" do
    p = Package.new(:name => "")
    assert !p.valid?
    assert_equal "can't be blank or contain trailing white space", p.errors[:name].to_s
    
    p = Package.new(:name => "Package   ")
    assert !p.valid?
    assert_equal "can't be blank or contain trailing white space", p.errors[:name].to_s
    
  end
  
end
