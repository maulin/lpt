require 'test_helper'

class HostTest < ActiveSupport::TestCase

  test "name must be unique" do
    host = Host.new(:name => "fedora")
    assert(!host.valid?)
    assert_equal(host.errors[:name].to_s, "has already been taken")
  end
  
end
