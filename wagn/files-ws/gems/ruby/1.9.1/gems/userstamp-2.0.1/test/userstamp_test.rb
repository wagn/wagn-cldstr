require 'test/helper'

class UserstampTests < ActiveSupport::TestCase
  test "it has a VERSION" do
    assert_match /^\d+\.\d+\.\d+$/, Userstamp::VERSION
  end
end
