# == Schema Information
#
#  id                :integer       not null, primary key
#  region_id         :integer
#  county_id         :integer
#  state_id          :integer
#  code              :string(10)    not null
#  name              :string(50)    not null
#  description       :text
#  start_description :text
#  turn_description  :text
#  city              :string(50)
#  latitude          :decimal(12, 8
#  longitude         :decimal(13, 8
#  turn_latitude     :decimal(12, 8
#  turn_longitude    :decimal(13, 8
#  location_notes    :text
#  length            :decimal(7, 5)
#  width             :string(10)
#  substrate         :string(20)
#  orientation       :string(10)
#  monitored         :boolean       default(TRUE)
#  access            :string(255)
#  ownership         :string(255)
#  geomorphology     :string(255)
#  vehicles_allowed  :boolean
#  vehicles_start    :integer
#  vehicles_end      :integer
#  dogs_allowed      :boolean
#  created_at        :datetime
#  updated_at        :datetime
#

class Beach < ActiveRecord::Base

  after_validation :resolve_state!

  belongs_to :state
  belongs_to :county
  belongs_to :region
  has_many :surveys
  has_many :volunteer_beaches, :dependent => :destroy

  LocationInvalid = [
    'LOCATION UNKNOWN',
    'Poor resolution'
  ]

  Geomorphology = [
    # Displayed    stored in db
    [ "Bay",          "bay"],
    [ "Spit",         "spit"],
    [ "Headland",     "headland"],
    [ "Unspecified",  nil]
  ]

  Orientation = [
    # Displayed     stored in db
    [ "East",       "E" ],
    [ "North",      "N" ],
    [ "Northeast",  "NE" ],
    [ "Northwest",  "NW" ],
    [ "South",      "S" ],
    [ "Southeast",  "SE" ],
    [ "Southwest",  "SW" ],
    [ "West",       "W" ]
  ]

  Width = [
    [ "Unspecified",    nil ],
    [ "Thin (<5m)",     "thin" ],
    [ "Medium (5-20m)", "med" ],
    [ "Wide (>20m)",    "wide" ],
  ]

  Access = [
    [ "Unspecified",  nil ],
    [ "Boat",         "boat" ],
    [ "Boat / Kayak", "boat/kayak" ],
    [ "Drive",        "drive" ],
    [ "Hike",         "hike" ],
    [ "Kayak",        "kayak" ],
    [ "Plane / Boat", "plane/boat" ],
    [ "Walk / Drive", "walk/drive" ],
  ]

  Substrate = [
    [ "Unspecified",  nil ],
    [ "Bedrock",      "bedrock" ],
    [ "Boulder",      "boulder" ],
    [ "Cobble",       "cobble" ],
    [ "Man-made",     "man-made" ],
    [ "Mud",          "mud" ],
    [ "Sand",         "sand" ],
  ]

  Ownership = [
    [ "Unspecified",     nil ],
    [ "Park",            "park" ],
    [ "Private",         "private" ],
    [ "Pubic",           "public" ],
    [ "Wildlife Refuge", "wildlife refuge" ],
  ]

  validates_inclusion_of :access, :in => Access.map {|disp, value| value}
  validates_inclusion_of :substrate, :in => Substrate.map {|disp, value| value}
  validates_inclusion_of :geomorphology, :in => Geomorphology.map {|disp, value| value}
  validates_inclusion_of :orientation, :in => Orientation.map {|disp, value| value}
  validates_inclusion_of :width, :in => Width.map {|disp, value| value}
  validates_uniqueness_of :code
  validates_length_of :code, :in => 4..8
  validates_inclusion_of :vehicles_start, :in => 1..12,
                         :if => Proc.new {|b| !b.vehicles_start.nil?}
  validates_inclusion_of :vehicles_end, :in => 1..12,
                         :if => Proc.new {|b| !b.vehicles_end.nil?}
  validates_presence_of :length
  validates_presence_of :code, :name
  validates_presence_of :region_id

  def self.find_active_beaches
    Beach.find_by_sql("SELECT * FROM beaches WHERE id IN (SELECT DISTINCT(beach_id) FROM surveys)")
  end

  # doing this through the @beach find is terribly slow (>12s runtime)
  def self.find_unverified_surveys_per_beach
    Beach.find_by_sql("SELECT beach_id, COUNT(beach_id)
                       FROM surveys WHERE verified IS false
                       GROUP BY beach_id").map_to_hash { |s|
                         {s.beach_id.to_i => s.count.to_i}
                       }
  end

  def validate
    if latitude? or longitude?
      validate_loc([latitude, longitude])
    end

    if turn_latitude? or turn_longitude?
      validate_loc([turn_latitude, turn_longitude])
    end

    if vehicles_allowed?
      errors.add("Vehicles allowed requires beginning and end dates") if
        !(1..12) === vehicles_start || !(1..12) === vehicles_end
    end
  end

  protected

  def validate_loc(loc)
    lat, long = loc
    if lat < -90 || lat > 90
      errors.add("Latitude must be in range -90 to 90")
    end

    if long < -180 || long > 180
      errors.add("Longitude must be in the the range -180 to 180")
    end
  end


  def resolve_state!
    # always force state to that of the parent region
    if not self.region.blank?
      self.state_id = self.region.state.id
    end
  end
end
