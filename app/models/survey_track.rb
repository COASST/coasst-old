# == Schema Information
#
#  id         :integer       not null, primary key
#  survey_id  :integer       not null
#  track_type :string(12)    not null
#  present    :boolean       not null
#  count      :integer
#

class SurveyTrack < ActiveRecord::Base
  belongs_to :survey

  TrackClass = [
    # display       store in db   tracks possible?
    [ 'Human',      'human',      true],
    [ 'Dog',        'dog',        true],
    [ 'Horse',      'horse',      true],
    [ 'Vehicle',    'vehicle',    true],
    [ 'ATV',        'atv',        true],
    [ 'Motor Bike', 'motor_bike', true],
    [ 'Kayaks',     'kayaks',     false],
  ]

  # just the short names names
  TrackNames = SurveyTrack::TrackClass.map {|t| t[1]}

  validates_inclusion_of    :track_type, :in => TrackClass.map{|a| a[1]}
  validates_numericality_of :count, :allow_nil => true, :only_integer => true

  # No data means there's no useful data stored and the SurveyTrack
  # can be deleted without losing much
  def has_data?
    if (not self.count.nil? and self.count > 0) or self.present == true
      true
    else
      false
    end
  end

  def human_track_type
    TrackClass.each do |t|
      if t[1] == self.track_type
        return t[0]
      end
    end
    return nil
  end

  def track_possible?
    TrackClass.each do |t|
      if t[1] == self.track_type
        return t[2]
      end
    end
    return nil
  end

end
