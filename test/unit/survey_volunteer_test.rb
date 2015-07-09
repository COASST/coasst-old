require File.dirname(__FILE__) + '/../test_helper'

class SurveyVolunteerTest < Test::Unit::TestCase
  #fixtures :survey_volunteers

  @@valid_roles = ['data collector', 'submitter']

  def test_should_accept_survey_and_volunteer_without_time
    sv = create
    assert sv.valid?, "Survey Volunteer was invalid:\n#{sv.to_yaml}"

  end

  def test_should_accept_survey_and_volunteer_with_time
    sv = create(:travel_time => 22)
    assert sv.valid?, "Survey Volunteer was invalid with travel time:\n#{sv.to_yaml}"
  end

  def test_should_have_valid_role
    sv = create
    assert sv.valid?, "Invalid Role found, should be 'data collector'"
  end

  def test_should_invalidate_invalid_role
    sv = create(:role => 'foo baz boss')
    deny sv.valid?, "Passed with bogus role"
  end

  # test the time parser
  def test_should_parse_time_formats
    assert_equal SurveyVolunteer.parse_travel_time('13'),  13, "Parse travel time: '13' failed."
    assert_equal SurveyVolunteer.parse_travel_time('1.5'), 90, "Parse travel time: '1.5' failed."
    assert_equal SurveyVolunteer.parse_travel_time('1.5hr'), 90, "Parse travel time: '1.5hr' failed."
    assert_equal SurveyVolunteer.parse_travel_time('-2'), 1, "Parse travel time: '-2' failed."
    assert_equal SurveyVolunteer.parse_travel_time('13min'), 13, "Parse travel time: '13min' failed."
  end

  def test_should_have_positive_travel_time
    sv = create(:travel_time => -1)
    deny sv.valid?, "travel time valid with negative duration:\n#{sv.to_yaml}"
  end

private

  def create(options={})
    s = create_survey
    sv = SurveyVolunteer.new({
      :role          => @@valid_roles[0],
      :volunteer_id => @@survey_volunteer.id,
      :survey_id    => s.id
    }.merge(options))
    sv.save
    sv
  end

  def create_survey
    s = Survey.new
    # new survey requires at least one volunteer
    s.add_volunteer(@@survey_volunteer)
    s.update_attributes(@@survey_default_values)
    s.save
    s
  end
end
