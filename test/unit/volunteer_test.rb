require File.dirname(__FILE__) + '/../test_helper'

class VolunteerTest < Test::Unit::TestCase
  fixtures :volunteers

  def test_invalid_with_empty_attributes
    volunteer = Volunteer.new
    assert !volunteer.valid?
    assert volunteer.errors.invalid?(:email)
    assert volunteer.errors.invalid?(:first_name)
    assert volunteer.errors.invalid?(:last_name)
  end

end
