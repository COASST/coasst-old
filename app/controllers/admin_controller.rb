class AdminController < ApplicationController

  require 'fastercsv'
  layout 'admin'

  before_filter do |controller|
    # send expected tole to check_authentication method
    controller.send(:check_authentication, 'verifier')
  end

  skip_after_filter :add_google_analytics_code

  def beach
    redirect_to :controller => :beach, :action => :index
  end

  def county
    redirect_to :controller => :county, :action => :index
  end

  def foot_type_family
    redirect_to :controller => :foot_type_family, :action => :index
  end

  def group
    redirect_to :controller => :group, :action => :index
  end

  def plumage
    redirect_to :controller => :plumage, :action => :index
  end

  def species
    redirect_to :controller => :species, :action => :index
  end

  def subgroup
    redirect_to :controller => :subgroup, :action => :index
  end

  def volunteer
    redirect_to :controller => :volunteer_data, :action => :index
  end

  def index

  end

  def export
    # two mm-dd-yyyy formatted dates
    if params[:start_date].nil? or params[:end_date].nil?
      return
    else
      start_date = Time.now.smart_parse(params[:start_date], nil, false, 'date')
      end_date = Time.now.smart_parse(params[:end_date], nil, false, 'date')
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
      s.is_survey,
      s.project,
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
      b.identification_level_family,
      b.identification_level_species,
      b.identification_level_group,
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
    survey_query =  "SELECT * FROM export_surveys_unmaterialized
      WHERE survey_date >= '#{start_date.strftime("%m-%d-%Y")}' AND
            survey_date <= '#{end_date.strftime("%m-%d-%Y")}'
      ORDER BY survey_date
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

    # map all tracks out to our surveys
    tl = mapped_tracks(tracks, ids)

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
          ["Human Present",       "tl[sid]['human'][:present]"],
          ["Human Count",         "tl[sid]['human'][:count]"],
          ["Dog Present",         "tl[sid]['dog'][:present]"],
          ["Dog Count",           "tl[sid]['dog'][:count]"],
          ["Horse Present",       "tl[sid]['horse'][:present]"],
          ["Horse Count",         "tl[sid]['horse'][:count]"],
          ["Vehicle Present",     "tl[sid]['vehicle'][:present]"],
          ["Vehicle Count",       "tl[sid]['vehicle'][:count]"],
          ["ATV Count",           "tl[sid]['atv'][:count]"],
          ["Motor Bike Count",    "tl[sid]['motor_bike'][:count]"],
          ["Kayak Count",         "tl[sid]['kayaks'][:count]"],
          ["Substrate",           "s.substrate"],
          ["Orientation",         "s.orientation"],
          ["Survey Comments",     "s.survey_comments"],
          ["Survey",              "s.survey_id"],
          ["Is Survey",           "s.is_survey"],
          ["Project",             "s.project"],
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
          ["Identification Level: Family","s.identification_level_family"],
          ["Identification Level: Species","s.identification_level_species"],
          ["Identification Level: Group/Subgroup","s.identification_level_group"],
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

    send_data output_csv, :type => "text/plain",
      :filename =>"coasst_#{start_date.strftime('%m-%d-%y')}_#{end_date.strftime('%m-%d-%y')}.csv",
      :disposition => 'attachment'

    # force garbage collection...
    GC.start
  end

private

  def join_elements(elements)
    # map the elements into 7 columns, maximum available in our output file
    dc = []
    ['', '', '', '', '', '', ''].fill {|x| dc[x] = elements[x]}
    if elements.length > 7:
      dc[6] = elements.slice(6, elements.length).join(",")
    end
    elements
  end

  def mapped_tracks(raw_tracks, ids)
    tracks = {}
    # prepopulate all tracks with empty entries
    ids.each do |id|
      id = id.to_i
      tracks[id.to_i] = {}
      # include all classes, including those we don't have tracks for
      SurveyTrack::TrackNames.each do |track_name|
        tracks[id][track_name] = {:present => '', :count => ''}
      end
    end
    # now look over our actual tracks, and populate where needed.
    raw_tracks.each do |track|
      # our records are sanitized and normalized, we want errors if tracks are invalid. 
      # only count can truly be empty.
      if tracks.has_key?(track.survey_id)
        if track.count.nil?
          count = 0 # as per https://mail.google.com/mail/u/0/#search/jane/144746b3f00babe8
        else
          count = track.count
        end
        tracks[track.survey_id][track.track_type] = {:present => track.present, :count => track.count}
      end
    end
    tracks
  end


end
