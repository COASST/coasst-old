ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase

  @@bird_default_values = {
    :survey_id          => 955,
    :species_id         => 114,
    :plumage_id         => 1,
    :age_id             => 2,
    :refound            => false,
    :collected          => false,
    :where_found        => 'Wrack',
    :foot_condition     => 'Stiff',
    :eyes               => 'Clear',
    :intact             => true,
    :head               => 'Present',
    :breast             => 'Present',
    :feet               => 'Both Feet Present',
    :wings              => 'Both Wings Present',
    :entangled          => 'Fishing Line',
    :entangled_comment  => "caught in fisherman's line",
    :oil                => true,
    :oil_comment        => "goopy tipped left wing",
    :sex                => 'Male',
    :bill_length        => 11,
    :wing_length        => 11,
    :tarsus_length      => 11,
    :tie_number         => "31",
    :tie_color_closest  => "3",
    :tie_color_middle   => "1",
    :tie_color_farthest => nil,
    :tie_location_comment => nil,
    :tie_other          => nil,
    :tie_location       => 'Right Wing',
    :photo_count        => 0,
    :verified           => false,
    :comment            => "what a find!",
    :is_bird            => true,
  }

  @@survey_default_values = {
      :beach_id         => 101, # only one existing survey
      :survey_date      => "2004-12-19",
      :code             => '579FrnCve121904',
      :end_time         => "15:15:00",
      :start_time       => "14:55:00",
      :duration         => "20",
      :weather          => 'Clouds',
      :oil_present      => true,
      :oil_size         => '100',
      :oil_sheen        => true,
      :oil_mousse       => true,
      :oil_goopy        => true,
      :oil_tarballs     => true,
      
      :wood_present     => true,
      :wood_size        => 'Small',
      :wood_continuity  => 'Patchy',
      :wood_zone        => 'High',

      :wrack_present    => true,
      :wrack_width      => 'Thin',
      :wrack_continuity => 'Patchy',
      :tracks_present   => false,
      :is_complete      => true,
      :is_survey        => true,
      :verified         => true,
      :comments         => "This is a test entry which should only be" + \
                           " used in the testing framework.",
  }
  
  @@survey_volunteer = Volunteer.find_by_email('billyblanks@bugmenot.com')
  
  @@survey_track_default_values = {
    :present => true,
    :track_type => 'human',
    :count => 3,
  }

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def deny(condition, message)
    assert !condition, message
  end
end
