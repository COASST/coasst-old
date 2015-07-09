require File.dirname(__FILE__) + '/../test_helper'

class BirdTest < Test::Unit::TestCase
  # fixtures are broken atm, generate our own test data inline
  #fixtures :birds

  def test_should_be_invalid_without_attributes
    default_attributes = [
      :survey_id, :species_id,
      :where_found, :foot_condition, :intact,
      :head, :breast, :eyes, :feet, :wings,
      :entangled, :oil, :photo_count,
    ]
    bird = Bird.new
    deny bird.valid?, "bird was valid without attributes\n#{bird.to_yaml}"
    default_attributes.each { |attr| assert bird.errors.invalid?(attr), "Bird valid without #{attr}." }
  end

  # plumage and age should be set if bird is an adult
  #def test_should_be_invalid_without_plumage_or_age_if_adult
  #  adult_attributes = [
  #    :plumage_id, :age_id,
  #  ]

  #  bird = Bird.new({:age_id => 1})
  #  adult_attributes.each { |attr| assert bird.errors.invalid?(attr), "Adult bird valid with #{attr}."}
  #end

  #def test_should_be_invalid_without_sex_if_sex_exists
  #  bird = Bird.new({:sex => true})
  #  assert bird.errors.invalid?(:sex), "Bird invalid with sex#{bird.to_yaml}"
  #end

  def test_should_require_oil_entangled_comments
    b = create(:oil_comment => nil, :entangled_comment => nil)

    deny b.valid?, "Oil and Entangled require comments\n #{b.to_yaml}"
    assert_not_nil b.errors.on(:oil_comment), "Error expected for missing oil comment"
    assert_not_nil b.errors.on(:entangled_comment), "Error expected for missing entangled comment"
  end

  def test_should_work_with_valid_defaults
    b = create

    assert b.valid?, "Expected default data to be valid\n#{b.to_yaml}"
  end

  def test_should_have_valid_tie_location
    b = create(:tie_location => 'Top-side spin')

    deny b.valid?, "Tie location requires valid selection\n#{b.to_yaml}"
    assert_not_nil b.errors.on(:tie_location), "Error expected for invalid tie location"
  end

  def test_should_have_tie_location_if_ties
    b = create(:tie_color_middle => 3, :tie_color_farthest => 1, :tie_location => nil)

    deny b.valid?, "Should error when no tie location with ties"
    assert_not_nil b.errors.on(:tie_location), "Error expected for missing tie location"
  end

  # was storing things as int, make sure changes stick
  def test_should_have_tie_number_match_ties_with_leading_zero
    b = create(:tie_color_closest => 0, :tie_color_middle => 3,
               :tie_color_farthest => 1, :tie_location => 'Left Wing')

    assert b.valid?, "Should be fine with lead zero in ties\n#{b.to_yaml}"
    assert_nil b.errors.on(:tie_number), "No error expected for tie number"
  end

  def test_should_have_tie_comment_if_multiple_ties
    b = create(:tie_location => 'Multiple')

    deny b.valid?, "Tie location comment required for multiple ties"
    assert_not_nil b.errors.on(:tie_location_comment), "Expected tie location comment for multiple ties\n#{b.to_yaml}"
  end

  def test_should_not_require_tie_location_without_ties
    b = create(:tie_color_closest => nil,
               :tie_color_middle => nil,
               :tie_color_farthest => nil,
               :tie_location => nil,
               :tie_number => nil)
    # ignore, tie now required.
    #assert b.valid?, "Tie location shouldn't be required when no ties are set\n#{b.to_yaml}"
  end

  def test_should_have_intact_fields_if_intact
    b = create(:intact => true, :head => false)

    # resolve_intact_fields runs pre-validation, and should catch this automatically
    assert b.valid?, "Intact requires subfields to be set accordingly, e.g. head == true"
  end

  # make sure that lengths aren't required when they're invalid
  def test_should_not_require_bill_length_if_no_head
    b = create(:head => false, :bill_length => nil)

    assert b.valid?, "Bill length shouldn't be required when bird has no head\n#{b.to_yaml}"
  end

  def test_should_not_require_wing_length_if_no_wings
    b = create(:wings => 'Wings Missing', :wing_length => nil)

    assert b.valid?, "Wing length shouldn't be required when bird has no wings\n#{b.to_yaml}"
  end

  def test_should_not_require_tarsus_length_if_no_feet
    b = create(:feet => 'Feet Missing', :tarsus_length => nil)

    assert b.valid?, "Tarsus length shouldn't be required when bird has no feet\n#{b.to_yaml}"
  end

private

  def create(options={})
    Bird.new(@@bird_default_values.merge(options))
  end

end
