# == Schema Information
#
#  id               :integer       not null, primary key
#  beach_id         :integer       not null
#  code             :string(17)    not null
#  survey_date      :date          not null
#  start_time       :time          not null
#  end_time         :time          not null
#  duration         :integer
#  weather          :string(255)
#  oil_present      :boolean
#  oil_frequency    :string(255)
#  oil_sheen        :boolean
#  oil_tarballs     :boolean
#  oil_goopy        :boolean
#  oil_mousse       :boolean
#  oil_comment      :text
#  wood_present     :boolean
#  wood_size        :string(255)
#  wood_continuity  :string(255)
#  wood_zone        :string(255)
#  wrack_present    :boolean
#  wrack_width      :string(255)
#  wrack_continuity :string(255)
#  tracks_present   :boolean
#  comments         :text
#  created_on       :datetime
#  updated_on       :datetime
#  verified         :boolean
#  is_survey        :boolean       default(TRUE)
#  is_complete      :boolean
#  project          :string(255)
#

require 'time_diff'

class Survey < ActiveRecord::Base

  after_create :finish_add_volunteers, :finish_volunteer_last_surveyed
  before_create :generate_code
  before_validation :resolve_physical_fields!

  belongs_to :beach

  has_many :birds, :dependent=>:destroy
  has_many :survey_tracks, :dependent=>:destroy
  has_many :survey_volunteers, :dependent=>:destroy
  has_many :volunteers, :through => :survey_volunteers

  Weather = [
    # display   store in db
    ['Sun',     'Sun'],
    ['Clouds',  'Clouds'],
    ['Fog',     'Fog'],
    ['Rain',    'Rain'],
    ['Snow',    'Snow']
  ]

  OilFrequency = [
    # display       store in db
    ['1 kilometer', '1000'],
    ['100 meters',  '100'],
    ['10 meters',   '10'],
    ['1 meter',     '1']
  ]

  OilTypes = [
    # display     column in db
    ['Sheen',     'oil_sheen'],
    ['Tarballs',  'oil_tarballs'],
    ['Goopy',     'oil_goopy'],
    ['Mousse',    'oil_mousse'],
  ]

  WoodTypes = [
    'wood_size', 'wood_continuity', 'wood_zone'
  ]

  WrackTypes = [
    'wrack_width', 'wrack_continuity'
  ]

  WoodSize = [
    # display         store in db
    ['Small (<20cm)', 'Small'],
    ['Medium',        'Medium'],
    ['Large (>1m)',   'Large'],
  ]

  Continuity = [
    ['Patchy',     'Patchy'],
    ['Continuous', 'Continuous'],
  ]

  WoodZone = [
    ['Low',  'Low'],
    ['High', 'High'],
  ]

  WrackWidth = [
    ['Thin (<1m wide)',  'Thin'],
    ['Thick',            'Thick'],
  ]

  Projects = [
    'COASST',
    'Marine Biology',
    'Scoter Wreck',
  ]

  # Epoch date is the first recorded date of a survey
  #  Survey.find_by_sql("SELECT MIN(survey_date) FROM surveys").
  Epoch = "1999-12-05"

  # Arbitrary number bigger than the number of steps we have
  STEP_COMPLETE = 4

  # These are temporary variables used during multistep process

  def initialize
    super

    self.verified = false
    self.is_complete = false
    @step = 1 # Steps completed
    @new_survey_volunteers = []
  end

  # Pass an array instead of text to message. the first index into the array is
  # the step number, second is the message.  Use special functions valid_step?(num) and errors_step(num)
  # to validate against only the step numbers and get errors for the number
  validates_presence_of   :beach_id,
                          :message=>[3, I18n.translate('activerecord.errors.messages')[:blank]]

  validates_inclusion_of  :oil_present, :in => [true, false],
                          :message=>[3, ": Please choose an option"]
  validates_inclusion_of  :oil_frequency, :in => OilFrequency.map {|x| x[1]},
                          :if => Proc.new { |s| s.oil_present?},
                          :message => [3, I18n.translate('activerecord.errors.messages')[:inclusion]]
  validates_presence_of   :oil_comment,
                          :if => Proc.new { |s| s.oil_present?},
                          :message => [3, 'required if beach was oiled']

  validates_inclusion_of  :wood_present, :in => [true, false],
                          :message=>[3, ": Please choose an option"]
  validates_inclusion_of  :wood_size, :in => WoodSize.map {|x| x[1]},
                          :if => Proc.new { |s| s.wood_present?},
                          :message=>[3, I18n.translate('activerecord.errors.messages')[:inclusion]]
  validates_inclusion_of  :wood_continuity, :in => Continuity.map {|x| x[1]},
                          :if => Proc.new { |s| s.wood_present?},
                          :message=>[3, I18n.translate('activerecord.errors.messages')[:inclusion]]
  validates_inclusion_of  :wood_zone, :in => WoodZone.map {|x| x[1]},
                          :if => Proc.new { |s| s.wood_present?},
                          :message=>[3, I18n.translate('activerecord.errors.messages')[:inclusion]]

  validates_inclusion_of  :wrack_present, :in => [true, false],
                          :message=>[3, ": Please choose an option"]
  validates_inclusion_of  :wrack_width, :in => WrackWidth.map {|x| x[1]},
                          :if => Proc.new { |s| s.wrack_present?},
                          :message => [3, I18n.translate('activerecord.errors.messages')[:inclusion]]
  validates_inclusion_of  :wrack_continuity, :in => Continuity.map {|x| x[1]},
                          :if => Proc.new { |s| s.wrack_present?},
                          :message => [3, I18n.translate('activerecord.errors.messages')[:inclusion]]

  validates_inclusion_of  :tracks_present, :in => [true, false],
                          :message=>[3, ": Please choose an option"]
  validates_inclusion_of  :weather, :in => Weather.map {|x| x[1]},
                          #:if => Proc.new { |s| !s.weather.nil? and !s.weather.empty? },
                          :message=>[3, I18n.translate('activerecord.errors.messages')[:inclusion]]
  validates_date          :survey_date,
                          :before => Proc.new { 1.day.from_now.to_date },
                          :message => [2, 'Invalid date'],
                          :before_message => [2, 'must be in the past']
  # verifier validation
  validates_presence_of  :project, :if => Proc.new { |s| s.verified? }

  def validate
    if !start_time.blank? and !end_time.blank?
      self.duration = time_diff_in_minutes(start_time, end_time)
      # make sure duration is positive
      errors.add_to_base([2,"Time range isn't valid"]) if self.duration < 1
    else
      errors.add_to_base([2,"Start time and end time are required."])
    end

    if all_volunteers('data collector').length < 1
      errors.add_to_base([1,"Survey must have at least one data collector"])
    end

    if oil_present?
      errors.add_to_base([3, "One type of oil must be selected"]) if !has_oil?
    end

    if not @tracks_present_selected.nil? and @tracks_present_selected == true
      if not tracks_present?
        errors.add_to_base([3,"If human data is selected, please enter data for at least one type of track"])
      end
    end

    # incompatible with our track workflow in step 3... only add the tracks to survey_tracks
    # after validation of the survey
    if tracks_present?
      #errors.add_to_base([3, "At least one track must be added"]) if track_list.length == 0
    end
  end

  def tracks_present?
    # bit verbose to deal with bug with dummy tracks being created
    survey_tracks.select {|t| t.present || (t.count and t.count > 0)}.length > 0 ? true : false
  end

  def tracks_present
    tracks_present?
  end

  def tracks_present=(val)
  end

  def add_volunteer(volunteer, role = 'data collector')
    roles = SurveyVolunteer::Roles.collect { |k,v| v }
    if !roles.include?(role)
      logger.error("Attempt to add volunteer #{volunteer.id} with invalid role #{role}")
      return nil
    end

    if @new_survey_volunteers.nil?
      @new_survey_volunteers = []
    end

    in_role = self.survey_volunteers.select {|v| v.role == role}
    if new_record?
      # For new records save results into temporary variables, we'll have
      # to add these after the survey is saved
      logger.info("add_volunteer: got a new record")
      @new_survey_volunteers.select {|v| v.role == role}.each do |sv|
        in_role << sv
      end

      if not in_role.include?(volunteer)
        new_v = SurveyVolunteer.new({
          :role => role,
          :volunteer_id => volunteer.id,
        })
        @new_survey_volunteers << new_v
      end
    else
      logger.info("add_volunteer: an existing record")
      if not in_role.include?(volunteer)
        logger.info("add_volunteer: in_role doesn't have volunteer, add them")
        #logger.info("add_volunteer: in_role: #{in_role.to_yaml}, volunteer: #{volunteer.to_yaml}")
        new_v = SurveyVolunteer.new({
          :role => role,
          :volunteer_id => volunteer.id,
          :survey_id => self.id
        })
        new_v.save!
        #logger.info("add_volunteer: added volunteer: #{new_v.to_yaml}")
      end
    end
  end

  def remove_volunteer(volunteer)
    self.survey_volunteers.each do |sv|
      if sv.volunteer_id == volunteer.id
        self.survey_volunteers.delete(sv)
        sv.destroy
      end
    end

    if not @new_survey_volunteers.nil? and not volunteer.nil?
      @new_survey_volunteers = @new_survey_volunteers.select {|sv| sv.volunteer_id != volunteer.id}
    end

    true
  end

  def all_survey_volunteers(role = nil)
    volunteers = []
    for v in self.survey_volunteers
      if role.nil? or role == v.role
        volunteers << v
      end
    end

    unless @new_survey_volunteers.nil?
      for v in @new_survey_volunteers
        if role.nil? or role == v.role
          volunteers << v
        end
      end
    end
    volunteers
  end

  def all_volunteers(role = nil)
    survey_volunteers = self.all_survey_volunteers
    volunteers = []
    for sv in survey_volunteers
      if role.nil? or role == sv.role
        volunteers << sv.volunteer
      end
    end
    volunteers.uniq
  end

  def data_collectors
    self.all_volunteers('data collector')
  end

  def submitter
    self.all_volunteers('submitter')
  end

  def errors_step(step)
    errors = []
    @errors.each do |attr,msg_a|
      logger.info("Got error #{msg_a}, #{msg_a[0]}, #{msg_a[1]}")
      if msg_a.class == Array
        if msg_a[0] == step
          if attr == "base"
            errors << msg_a[1]
          else
            errors << Survey.human_attribute_name(attr) + " " + msg_a[1]
          end
        end
      end
    end
    errors
  end

  def valid_step?(step)
    valid?
    errors_step(step).empty?
  end

  def all_errors
    errors = []
    @errors.each do |attr,msg_a|
      if attr == "base"
        errors << msg_a[1].to_s
      else
        errors << Survey.human_attribute_name(attr) + " " + msg_a[1].to_s
      end
    end
    errors
  end

  def step
    if new_record?
      @step
    else
      STEP_COMPLETE
    end
  end

  def step=(step)
    @step = step
  end

  def oil_types
    types = []
    OilTypes.collect {|t| t[1]}.each do |type|
      if send(type)
        types << type
      end
    end
    types
  end

  # send it an array of column names i.e. ['oil_goopy','oil_sheen']
  def oil_types=(vals = [])
    if vals.is_a?(Array)
      OilTypes.collect {|t| t[1]}.each do |type|
        if vals.member?(type)
          send(type+"=",true)
        else
          send(type+"=",false)
        end
      end
    end
  end

  def has_tracks?
    survey_tracks.length > 0
  end

  def has_oil?
    oil_types.length > 0
  end

  def generate_code
    if self.code.nil?
      my_code = ""
      my_code += beach.code
      my_code += survey_date.strftime("%m%d%y")
      self.code = my_code
    end
  end

  def to_label
    "Survey: #{self.survey_date}"
  end

  def export_results(start_date_in, end_date_in, export_dir="tmp/data")
    (start_date, end_date) = get_dates(start_date_in, end_date_in)
    if start_date.nil? or end_date.nil?
      return
    end

      # removed b.code as bird_code, no longer generated
    survey_query = "
      SELECT
      EXTRACT(day FROM s.survey_date) AS survey_day,
      EXTRACT(month FROM s.survey_date) AS survey_day,
      EXTRACT(year FROM s.survey_date) AS survey_day,
      s.survey_date,
      s.id   AS survey_id,
      s.code AS survey_code,
      b.id   AS bird_code,
      r.name AS region,
      be.name as beach_name,
      be.length as beach_length,
      to_char(s.start_time, 'HH24:MI') AS survey_start_time,
      to_char(s.end_time, 'HH24:MI') AS survey_end_time,
      s.duration,
      s.weather,
      s.oil_present,
      s.oil_frequency,
      s.oil_sheen,
      s.oil_tarballs,
      s.oil_goopy,
      s.oil_mousse,
      s.oil_comment AS survey_oil_comment,
      s.wood_present,
      s.wood_size,
      s.wood_continuity,
      s.wood_zone,
      s.wrack_present,
      s.wrack_width,
      s.wrack_continuity,
      s.verified,
      be.substrate,
      be.orientation,
      s.comments AS survey_comments,
      b.verified AS bird_verified,
      b.refound AS bird_refound,
      b.where_found as bird_where_found,
      b.foot_condition,
      b.eyes,
      b.intact,
      b.head AS head_present,
      b.breast AS breast_present,
      b.feet,
      b.wings,
      b.entangled,
      b.entangled_comment,
      b.oil,
      b.oil_comment,
      b.sex,
      b.collected,
      b.collected_comment,
      b.photo_count,
      b.tie_location,
      b.tie_location_comment,
      b.tie_number,
      b.is_bird,
      b.comment,
      b.verification_comment,
      b.identification_level,
      b.tie_other,
      sp.name AS species_name,
      g.name AS group_name,
      sg.name AS subgroup_name,
      a.name AS age,
      pl.name AS plumage,
      b.bill_length,
      b.wing_length,
      b.tarsus_length
      FROM surveys s
      LEFT JOIN birds b ON s.id = b.survey_id
      LEFT JOIN plumages pl ON pl.id = b.plumage_id
      LEFT JOIN ages a ON a.id = b.age_id
      LEFT JOIN species sp ON sp.id = b.species_id
      LEFT JOIN groups g ON g.id = b.group_id
      LEFT JOIN subgroups sg ON sg.id = b.subgroup_id
      LEFT JOIN beaches be ON s.beach_id = be.id
      LEFT JOIN regions r ON be.region_id = r.id
      WHERE s.survey_date >= '#{start_date.strftime("%m-%d-%Y")}' AND
            s.survey_date <= '#{end_date.strftime("%m-%d-%Y")}'
      ORDER BY s.survey_date;
    "

    surveys = Survey.find_by_sql(survey_query)
    if surveys.size == 0
      flash[:notice] = "No surveys found in given date range."
      render :action => :export
      return
    end

    ids = surveys.map {|s| s.survey_id}

    # if we have less than 10k results, return only those listed.
    # with more than ~10k, the parsing the string outweighs the benefit
    if ids.size < 10000
      condition = "survey_id in (#{ids.join(",")})"
      tracks = SurveyTrack.find(:all, :conditions => condition)
      survey_volunteers = SurveyVolunteer.find(:all, :conditions => condition)
    else
      tracks = SurveyTrack.find(:all)
      survey_volunteers = SurveyVolunteer.find(:all)
    end
    volunteers = {}
    Volunteer.find(:all).map {|v| volunteers[v.id] = v.fullname} # 300ms

    # get column names, prettify them
    columns = surveys.first.attributes.keys.map {|c| c.titleize}

    tl = {}
    # this is inelegant, but that's why you don't program at 2am while sick
    classes = SurveyTrack::TrackClass.map {|a| a[1]}
    counts = classes.map {|c| "#{c}_count"}.flatten
    present = classes.map {|c| "#{c}_present"}.flatten
    track_types = {}
    counts.each {|c| track_types[c] = 0}
    present.each {|c| track_types[c] = false}

    # assign the default blank values for every id, to prevent failure for surveys with no tracks
    ids.each do |id|
      #logger.info "duping data for #{id.to_i}"
      tl[id.to_i] = track_types.m_dup
    end

    tracks.each do |track|
      if not (track.survey_id.nil? and track.track_type.nil? and track.present.nil? and track.count.nil?)
        #logger.error "at #{track.survey_id}, #{track.count}, #{track.present}"
        tl[track.survey_id] = {}
        tl[track.survey_id]["#{track.track_type}_present"] = track.present
        tl[track.survey_id]["#{track.track_type}_count"] = track.count
      end
    end

    # only care about two roles for the report
    roles = {'submitter' => [], 'data collector' => [], 'travel time' => []}
    vl = {}
    survey_volunteers.each do |sv|
      if not vl.has_key?(sv.survey_id)
        vl[sv.survey_id] = roles.m_dup
      end
      if roles.has_key?(sv.role)
        vl[sv.survey_id][sv.role] << volunteers[sv.volunteer_id]
        # also include travel time for data collectors
        if sv.role == 'data collector'
          vl[sv.survey_id]['travel time'] << sv.travel_time
        end
      end
    end

    vl.each do |k, v|
      v.each do |i, j|
        if i == 'submitter'
          vl[k][i] = j.join(',')
        else
          # map the data into 7 columns
          vl[k][i] = join_elements(j)
        end
      end
    end

    # set dummy data to prevent replicating the mapping table
    s = surveys.first
    sid = s.survey_id.to_i

    table_map = [
          ["Survey Date",         "s.survey_date.to_s"],
          ["Day",                 "s.survey_date.day"],
          ["Month",               "Date::ABBR_MONTHNAMES[s.survey_date.month]"],
          ["Year",                "s.survey_date.year"],
          ["Survey Code",         "s.survey_code"],
          ["Bird Code",           "s.bird_code"],
          ["Submitter",           "vl[sid]['submitter']"],
          ["Data Collector",      "vl[sid]['data collector'][0]"],
          ["Data Collector #2",   "vl[sid]['data collector'][1]"],
          ["Data Collector #3",   "vl[sid]['data collector'][2]"],
          ["Data Collector #4",   "vl[sid]['data collector'][3]"],
          ["Data Collector #5",   "vl[sid]['data collector'][4]"],
          ["Data Collector #6",   "vl[sid]['data collector'][5]"],
          ["Data Collector #7",   "vl[sid]['data collector'][6]"],
          ["Travel Time",         "vl[sid]['travel time'][0]"],
          ["Travel Time #2",      "vl[sid]['travel time'][1]"],
          ["Travel Time #3",      "vl[sid]['travel time'][2]"],
          ["Travel Time #4",      "vl[sid]['travel time'][3]"],
          ["Travel Time #5",      "vl[sid]['travel time'][4]"],
          ["Travel Time #6",      "vl[sid]['travel time'][5]"],
          ["Travel Time #7",      "vl[sid]['travel time'][6]"],
          ["Region",              "s.region"],
          ["Beach Name",          "s.beach_name"],
          ["Beach Length",        "s.beach_length"],
          ["Survey Start Time",   "s.survey_start_time"],
          ["Survey End Time",     "s.survey_end_time"],
          ["Duration",            "s.duration"],
          ["Weather",             "s.weather"],
          ["Oil Present Beach",   "s.oil_present"],
          ["Oil Frequency",       "s.oil_frequency"],
          ["Oil Sheen",           "s.oil_sheen"],
          ["Oil Tarballs",        "s.oil_tarballs"],
          ["Oil Goopy",           "s.oil_goopy"],
          ["Oil Mousse",          "s.oil_mousse"],
          ["Survey Oil Comment",  "s.survey_oil_comment"],
          ["Wood Present",        "s.wood_present"],
          ["Wood Size",           "s.wood_size"],
          ["Wood Continuity",     "s.wood_continuity"],
          ["Wood Zone",           "s.wood_zone"],
          ["Wrack Present",       "s.wrack_present"],
          ["Wrack Continuity",    "s.wrack_continuity"],
          ["Wrack Width",         "s.wrack_width"],
          ["Human Present",       "tl[sid]['human_present']"],
          ["Human Count",         "tl[sid]['human_count']"],
          ["Dog Present",         "tl[sid]['dog_present']"],
          ["Dog Count",           "tl[sid]['dog_count']"],
          ["Horse Present",       "tl[sid]['horse_present']"],
          ["Horse Count",         "tl[sid]['horse_count']"],
          ["Vehicle Present",     "tl[sid]['vehicle_present']"],
          ["Vehicle Count",       "tl[sid]['vehicle_count']"],
          ["ATV Count",           "tl[sid]['atv_count']"],
          ["Motor Bike Count",    "tl[sid]['motor_bike_count']"],
          ["Kayak Count",         "tl[sid]['kayaks_count']"],
          ["Substrate",           "s.substrate"],
          ["Orientation",         "s.orientation"],
          ["Survey Comments",     "s.survey_comments"],
          ["Survey",              "s.survey_id"],
          ["Bird Refound",        "s.bird_refound"],
          ["Bird Where Found",    "s.bird_where_found"],
          ["Collected",           "s.collected"],
          ["Collected Comment",   "s.collected_comment"],
          ["Foot Condition",      "s.foot_condition"],
          ["Eyes",                "s.eyes"],
          ["Intact",              "s.intact"],
          ["Head Present",        "s.head_present"],
          ["Breast Present",      "s.breast_present"],
          ["Feet",                "s.feet"],
          ["Wings",               "s.wings"],
          ["Entangled",           "s.entangled"],
          ["Entangled Comment",   "s.entangled_comment"],
          ["Oil Bird",            "s.oil"],
          ["Bird Oil Comment",    "s.oil_comment"],
          ["Tie Number",          "s.tie_number"],
          ["Tie Other",           "s.tie_other"],
          ["Tie Location",        "s.tie_location"],
          ["Species Name",        "s.species_name"],
          ["Subgroup Name",       "s.subgroup_name"],
          ["Group Name",          "s.group_name"],
          ["Age",                 "s.age"],
          ["Sex",                 "s.sex"],
          ["Plumage",             "s.plumage"],
          ["Bill Length",         "s.bill_length"],
          ["Wing Length",         "s.wing_length"],
          ["Tarsus Length",       "s.tarsus_length"],
          ["Comment",             "s.comment"],
          ["Bird Verified",       "s.bird_verified"],
          ["Is Bird",             "s.is_bird"],
          ["Identification Level","s.identification_level"],
          ["Photo Count",         "s.photo_count"],
          ["Verified",            "s.verified"],
          ["Verification Comment","s.verification_comment"],
    ]

    bad_sids = []
    output_csv = FasterCSV.generate do |csv|
      # Output header to CSV
      csv << table_map.map {|t| t[0]}

      surveys.each do |s|
        sid = s.survey_id.to_i
        values = []
        table_map.map do |t|
          begin
            val = eval(t[1])
          rescue
            logger.info("recieved an exception with #{t[0]} in survey #{sid}")
            if not bad_sids.include? sid
              bad_sids.push(sid)
            end
          end
          if val.class == TrueClass
            val = val.to_bs
          elsif val.class == FalseClass
            val = val.to_bs
          # fix the mismapped booleans
          elsif val == 't'
            val = 'Yes'
          elsif val == 'f'
            val = 'No'
          else
            # leave it be
          end
          values << val
        end
        csv << values
      end
    end

    bad_sids.each do |sid|
      VolunteerNotifier.deliver_survey_missing_volunteers(Survey.find(sid))
    end

    filename = "coasst_#{start_date.strftime('%m-%d-%y')}_#{end_date.strftime('%m-%d-%y')}.csv"
    logger.info("CSV received, writing to #{export_dir}/#{filename}")
    File.open("#{export_dir}/#{filename}", 'w') {|f| f.write(output_csv)}
  end


  protected

  def finish_add_volunteers
    if not @new_survey_volunteers.nil?
      for sv in @new_survey_volunteers
        sv.survey_id = self.id
        sv.save
      end
    end
    @new_survey_volunteers = []
    self.reload
  end

  def finish_volunteer_last_surveyed
    # update each volunteer with this survey as last surveyed date
    volunteers = Volunteer.find(:all,
                                :conditions => ['id IN (?)', self.all_volunteers])
    survey_date = self.survey_date
    for v in volunteers
      if v.last_surveyed_date.nil? or v.last_surveyed_date < survey_date
        v.last_surveyed_date = survey_date
        v.save
      end
    end
  end

  def resolve_physical_fields!
    # using update_attributes calls this method as it runs validation, causing
    # a recursive loop.  Just copy attributes and overwrite.
    attr = self.attributes
    update_mappings = {
      'oil_present' => OilTypes.map {|name, db| db},
      'wood_present' => WoodTypes,
      'wrack_present' => WrackTypes,
    }

    update_mappings.each do |field, field_values|
      if self.attributes[field].blank?
        field_values.each { |field_attr|
          attr[field_attr] = nil
        }
      end
    end
    self.attributes = attr
  end

  def get_dates(start_date, end_date)
    ret = []
    [start_date, end_date].each do |d|
      ret << Time.now.smart_parse(d, nil, false, 'date')
    end
    ret
  end

  def join_elements(elements)
    # map the elements into 7 columns, maximum available in our output file
    dc = []
    ['', '', '', '', '', '', ''].fill {|x| dc[x] = elements[x]}
    if elements.length > 7:
      dc[6] = elements.slice(6, elements.length).join(",")
    end
    elements
  end

end
