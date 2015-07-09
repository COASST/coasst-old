require File.dirname(__FILE__) + '/../test_helper'

class SurveyTest < Test::Unit::TestCase
  # fixtures working here, but dragging butt... use sqlite memory fixtures? fk issues?
  #fixtures :surveys

  # @@survey_default_values contains a valid entry, should fly
  def test_should_work_with_valid_defaults
    survey = create
    assert survey.valid?, "Survey was invalid:\n#{survey.to_yaml}"
    assert_equal time_diff_in_minutes(survey.start_time, survey.end_time), survey.duration
  end

  def test_should_require_date
    survey = create(:survey_date => nil)
    deny survey.valid?, "Survey was valid without a date"
    assert_equal [2, "Invalid date"], survey.errors.on(:survey_date)
  end

  # don't allow dates in the future
  def test_should_contain_valid_date
    survey = create(:survey_date => Date.today + 1.day)

    deny survey.valid?, "Survey valid with future date"
    deny survey.valid_step?(2), "Survey valid at step two with future date"
  end

  def test_should_have_volunteer
    survey = create
    survey.remove_volunteer(@@survey_volunteer)

    deny survey.valid?, "Survey was valid without a volunteer\n#{survey.to_yaml}"
    assert_equal [1, 'Survey must have at least one volunteer'], survey.errors['base']
  end

  def test_should_have_valid_duration

  end

  def test_should_require_boolean_values_selected
    booleans_to_test = [
      :wood_present,
      :wrack_present,
      :oil_present,
      :tracks_present,
    ]

    booleans_to_test.each { |boolean|
      survey = create(boolean => nil)
      deny survey.valid?, "Survey was valid without #{boolean}\n#{survey.to_yaml}"
      assert_not_nil survey.errors.on(boolean), "Error not found for #{boolean}\n#{survey.to_yaml}"
    }
  end

  # check for the existence of human data
  def test_should_validate_tracks
    survey = create(:tracks_present => true)

    deny survey.has_tracks?, "Survey shouldn't contain any tracks"

    # replace with integration testing? save_tracks in data controller
    survey = create_survey_with_track
    assert survey.has_tracks?, "Survey doesn't contain any tracks"
    assert_equal survey.survey_tracks.count, 1, "Survey should have exactly 1 track"
  end

  def test_should_have_track_data_if_tracks
    survey = create(:tracks_present => true)

    deny survey.valid?, "Survey shouldn't be valid without track_data if tracks\n#{survey.to_yaml}"

    survey = create(:tracks_present => false)
    survey.survey_tracks << create_track({:survey_id => survey.id})
    survey.tracks_present = true
    assert survey.valid?, "Survey has a track, should be valid"
  end

  def test_should_have_oil_type_if_oil
    survey = create(:oil_present => true)
    survey.oil_types=[] # unset all the oil_types

    deny survey.valid?, "Error not found for no oil types\n#{survey.to_yaml}"
    deny survey.has_oil?, "has_oil? reports oil, but none present"
    survey.oil_types=['oil_goopy']
    assert survey.valid?, "Survey should have oil type"
  end

  def test_should_have_oil_size_if_oil
    survey = create(:oil_present => true, :oil_size => nil)
      deny survey.valid?, "Error not found for no oil size\n#{survey.to_yaml}"

    survey.update_attributes(:oil_size => '100')
    assert survey.valid?, "Survey should have valid oil size"
  end

  def test_should_have_wrack_width_if_wrack
    survey = create(:wrack_present => true, :wrack_width => nil)
    deny survey.valid?, "Survey valid without wrack width"
  end

  def test_should_have_wrack_continuity_if_wrack
    survey = create(:wrack_present => true, :wrack_continuity => nil)
    deny survey.valid?, "Survey valid without wrack continuity"
  end

  def test_should_have_wood_size_if_wood
    survey = create(:wood_present => true, :wood_size => nil)
    deny survey.valid?, "Survey valid without wood size"
  end

  def test_should_have_wood_continuity_if_wood
    survey = create(:wood_present => true, :wood_continuity => nil)
    deny survey.valid?, "Survey valid without wood continuity"
  end

  def test_should_have_wood_zone_if_wood
    survey = create(:wood_present => true, :wood_zone => nil)
    deny survey.valid?, "Survey valid without wood zone"
  end

private

  def create(options={})
    # can't use standard new / create method because of the overloading we do on surveys
    s = Survey.new
    # new survey requires at least one volunteer
    s.add_volunteer(@@survey_volunteer)
    s.update_attributes(@@survey_default_values.merge(options))
    #s.save
    s
  end

  def create_track(options={})
    st = SurveyTrack.new
    st.update_attributes(@@survey_track_default_values.merge(options))
    st
  end

  def create_survey_with_track(options={}, track_options={})
    survey = create(options)
    survey.survey_tracks << create_track({:survey_id => survey.id}.merge(track_options))
    survey
  end
end
