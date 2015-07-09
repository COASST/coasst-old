# == Schema Information
#
#  id           :integer       not null, primary key
#  survey_id    :integer       not null
#  volunteer_id :integer       not null
#  travel_time  :integer
#  role         :string(20)
#

class SurveyVolunteer < ActiveRecord::Base

  belongs_to :survey
  belongs_to :volunteer

  Roles = [
    # display   store in db
    ['Web Submitter',    'submitter'],
    ['Notetaker',        'notetaker'],
    ['Data Collector',   'data collector'],
    ['Volunteer',        'volunteer']
  ]

  validates_inclusion_of :role, :in => Roles.map {|disp, value| value}
  validates_inclusion_of :travel_time, :in => 0..1000,
                         :if => Proc.new { |sv| !sv.travel_time.nil?}

  def self.last_travel_time(volunteer_id,beach_id)
    if not volunteer_id.nil? and not beach_id.nil? and volunteer_id.to_i > 0 and beach_id.to_i > 0
      sql = "SELECT survey_volunteers.id,survey_volunteers.travel_time " +
            " FROM survey_volunteers, surveys " +
            " WHERE surveys.id = survey_volunteers.survey_id " +
            " AND survey_volunteers.travel_time IS NOT NULL " +
            " AND surveys.beach_id = ? " +
            " AND volunteer_id = ? " +
            " ORDER BY surveys.id DESC LIMIT 1"
      results = SurveyVolunteer.find_by_sql([sql,beach_id,volunteer_id])
      if results.length > 0
        results[0].travel_time
      else
        ""
      end
    end
  end

  def self.parse_travel_time(time)
    # parse basic time formats: 1hr, 90min, plain numbers are minutes,
    #                           decimal numbers are hours.
    time_regex = Regexp.new(/^(\d+(\.\d+)?)(\s+)?(\w+)?$/x)

    match = time_regex.match(time)
    if match.nil? or (match[2].nil? and match[4].nil?)
      # treat it as a bare number
      out_time = time.to_i
    else
      # time has units speficied, use a quick shortcut:
      #   anything with 'h' is hours, 'm' is minutes
      if match[4] =~ /m/i
        out_time = match[1].to_i
      elsif match[4] =~ /h/i or not match[2].nil?
        out_time = match[1].to_f * 60
      else
        out_time = nil
      end
    end

    if not out_time.nil? and out_time < 0
      return 1
    else
      return out_time
    end
  end

end
