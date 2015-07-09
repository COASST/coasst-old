class VolunteerDataController < ApplicationController

  require 'fastercsv'
  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :volunteer do |config|

    actions.exclude :search
    actions.add :live_search

    # link configuration
    delete.link.confirm = "Delete volunteer?"
    show.link.page = true

    action_links.add 'export_volunteers', :label => 'Export to CSV', :page => true
    action_links.add 'export_mailinglist', :label => 'Mailing CSV', :page => true
    action_links.add 'export_stats', :label => 'Stats CSV', :page => true

    # global columns configuration
    columns[:contact_time_of_day].label = "Best time to contact"
    columns[:contact_method].label = "Contact method preference"
    columns[:trained_age].label = "Age at time of training"

    columns[:first_name].options = {:size => 20}
    columns[:middle_initial].options = {:size => 1}
    columns[:last_name].options = {:size => 20}
    columns[:zip].options = {:size => 3}
    columns[:city].options = {:size => 20}
    columns[:mailing_list_expiration].options = {:time => false, :size => 10}
    columns[:trained_date].options = {:time => false, :size => 10}
    columns[:trained_age].options = {:size => 3}
    columns[:quiz_score_live_family].options = {:size => 3}
    columns[:quiz_score_live_spp].options = {:size => 3}
    columns[:quiz_score_dead_family].options = {:size => 3}
    columns[:quiz_score_dead_spp].options = {:size => 3}
    columns[:deposit_check_number].options = {:size => 10}
    columns[:deposit_return_date].options = {:time => false, :size => 10}
    columns[:widthdrawn_date].options = {:time => false, :size => 10}
    columns[:inactive_date].options = {:time => false, :size => 10}
    columns[:kit_return_date].options = {:time => false, :size => 10}

    # list options
    list.columns = [:first_name, :last_name, :nickname, :email, :phone, :status, :last_surveyed_date]
    config.list.sorting = { :last_name => :asc}
    # this wasn't working to add 'sortable' for this col
    #config.columns[:status].sort_by :sql => 'status'
    list.per_page = 25

    # attributes used in create & update
    exclude_columns = [:beaches, :friends, :surveys, :survey_volunteers, :volunteer_friends, :volunteer_beaches, :fullname]
    exclude_columns_create = [:active, :ended_on, :has_account, :hashed_password, :reset_password_code, :reset_password_code_until, :salt]
    name_columns = [:first_name, :middle_initial, :last_name, :nickname]
    contact_columns = [:street_address, :city, :state, :zip, :phone, :extension, :email, :contact_time_of_day, :contact_method]
    training_columns = [:occupation, :occupations, :employer, :gender, :hazwoper_trained, :trained_age, :trained_date, :find_us, :find_us_category, :involvement, :involvements, :birding_experience, :quiz_score_live_family, :quiz_score_live_spp, :quiz_score_dead_family, :quiz_score_dead_spp]
    mailing_columns = [:mailing_list, :mailing_list_expiration]
    directory_columns = [:directory, :directory_phone, :directory_email, :directory_guest, :directory_substitute]
    response_columns = [:organizations, :volunteer_comments]
    finance_columns = [:deposit_type, :deposit_amount, :deposit_check_number, :deposit_return_date, :deposit_return_type, :donor]
    widthdrawl_columns = [:substitute_only, :widthdrawn, :widthdrawn_date, :widthdrawn_reason, :inactive_date, :kit_type, :kit_return_date]
    metadata_columns = [:notes, :roles]

    # creation options
    create.columns.exclude exclude_columns + exclude_columns_create
    create.link.label = "Add new volunteer"

    create.columns.add_subgroup "Name" do |name_group|
      name_group.add name_columns
    end

    create.columns.add_subgroup "Contact" do |contact_group|
      contact_group.add contact_columns
    end

    create.columns.add_subgroup "Training" do |training_group|
      training_group.add training_columns
      training_group.collapsed = true
    end

    create.columns.add_subgroup "Mailing List" do |mailing_group|
      mailing_group.add mailing_columns
    end

    create.columns.add_subgroup "Directory" do |directory_group|
      directory_group.add directory_columns
      directory_group.collapsed = true
    end

    create.columns.add_subgroup "Additional Information" do |response_group|
      response_group.add response_columns
      response_group.collapsed = true
    end

    create.columns.add_subgroup "Financial" do |finance_group|
      finance_group.add finance_columns
      finance_group.collapsed = true
    end

    create.columns.add_subgroup "Widthdrawl" do |widthdrawl_group|
      widthdrawl_group.add widthdrawl_columns
      widthdrawl_group.collapsed = true
    end

    create.columns.add_subgroup "Metadata" do |metadata_group|
      metadata_group.add metadata_columns
    end

    # update options
    update.columns.exclude exclude_columns

    update.columns.add_subgroup "Name" do |name_group|
      name_group.add name_columns
    end

    update.columns.add_subgroup "Contact" do |contact_group|
      contact_group.add contact_columns
    end

    update.columns.add_subgroup "Training" do |training_group|
      training_group.add training_columns
    end

    update.columns.add_subgroup "Mailing List" do |mailing_group|
      mailing_group.add mailing_columns
    end

    update.columns.add_subgroup "Directory" do |directory_group|
      directory_group.add directory_columns
    end

    update.columns.add_subgroup "Additional Information" do |response_group|
      response_group.add response_columns
    end

    update.columns.add_subgroup "Financial" do |finance_group|
      finance_group.add finance_columns
    end

    update.columns.add_subgroup "Widthdrawl" do |widthdrawl_group|
      widthdrawl_group.add widthdrawl_columns
      widthdrawl_group.collapsed = true
    end

    update.columns.add_subgroup "Settings" do |settings_group|
      settings_group.add :active, :has_account, :ended_on, :hashed_password,
        :reset_password_code, :reset_password_code_until, :salt
      settings_group.collapsed = true
    end

    update.columns.add_subgroup "Metadata" do |metadata_group|
      metadata_group.add metadata_columns
    end

    # don't allow manipulation of these tables, just provide select list
    [:roles, :occupations, :involvements].each do |select|
      columns[select].form_ui = :select
    end

    #[:directory, :directory_phone, :directory_email, :directory_guest, :mailing_list].each do |select|
    #  columns[select].form_ui = :radio
    #  columns[select].options[:options] = [['Included', 'True'], ['Excluded', 'False']]
    #end

    # Minimum fields neccessary for a valid volunteer
    [:first_name, :last_name, :email].each do |req|
      columns[req].required = true
    end
  end


  def show
    @volunteer = Volunteer.find(params[:id])
    @volunteer_surveys = @volunteer.surveys.find(:all,
                            :conditions => 'is_complete is TRUE',
                            :order => 'survey_date DESC',
                            :include => [{:birds => :species}])

    @bird_count = @volunteer_surveys.map {|s| s.birds.length}.inject(0) {|sum,cnt| sum += cnt.to_i}
  end

  def export_mailinglist
    condition = 'active is TRUE AND mailing_list is TRUE'
    export(condition, 'volunteer_mailinglist')
  end

  def export_volunteers
    volunteer_query = "
      SELECT
      v.*
      FROM volunteers v
      ORDER BY v.last_name;
    "
    volunteers = Volunteer.find_by_sql(volunteer_query)

    if volunteers.size == 0
      flash[:notice] = "No volunteers found in given date range."
      return
    end

    ids = volunteers.map {|v| v.id}

    # set dummy data to prevent replicating the mapping table
    #s = surveys.first
    #sid = s.survey_id.to_i

    # pull out the last surveyed beach name
    last_beach = {}
    last_surveyed_beach_query = "
      SELECT volunteer_id,
        max(survey_date) as survey_date,
        max(be.name) AS beach_name
      FROM surveys s
      LEFT JOIN survey_volunteers sv ON sv.survey_id = s.id
      LEFT JOIN beaches be ON s.beach_id = be.id
      WHERE role = 'data collector'
      GROUP by volunteer_id"
    last_surveyed_res = Survey.connection.execute(last_surveyed_beach_query)
    last_surveyed_res.each do |r|
       vid = r['volunteer_id'].to_i
       last_beach[vid] = r['beach_name']
    end


    state_prefixes = {}
    State.all_states.each {|s| state_prefixes[s.id] = s.prefix}

    table_map = [
          ["Id", "v.id"],
          ["First Name", "v.first_name"],
          ["Middle Initial", "v.middle_initial"],
          ["Last Name", "v.last_name"],
          ["Full Name", "v.fullname"],
          ["Nickname", "v.nickname"],
          ["Email", "v.email"],
          ["Phone", "v.phone"],
          ["Extension", "v.extension"],
          ["Street Address", "v.street_address"],
          ["City", "v.city"],
          ["Zip", "v.zip"],
          ["State", "state_prefixes[v.state_id]"],
          ["Is Active?", "v.active"],
          ["Has Account?", "v.has_account"],
          ["Gender", "v.gender"],
          ["HAZWOPER Trained", "v.hazwoper_trained"],
          ["Trained Age", "v.trained_age"],
          ["Occupation", "v.occupation"],
          ["Occupation Categories", "v.occupations.map {|o| o.name}.join(',')"], # XXX
          ["Employer", "v.employer"],
          ["Organizations", "v.organizations"],
          ["Best time of day for contacting", "v.contact_time_of_day"],
          ["Best method for contacting", "v.contact_method"],
          ["Trained Date", "v.trained_date"],
          ["Find Us", "v.find_us"],
          ["Find Us Category", "v.find_us_category"],
          ["Involvement", "v.involvement"],
          ["Involvement Categories", "v.involvements.map {|i| i.name}.join(',')"], # XXX
          ["Birding Experience", "v.birding_experience"],
          ["Volunteer Comments", "v.volunteer_comments"],
          ["Quiz Score: Live to Family", "v.quiz_score_live_family"],
          ["Quiz Score: Live to Species", "v.quiz_score_live_spp"],
          ["Quiz Score: Dead to Family", "v.quiz_score_dead_family"],
          ["Quiz Score: Dead to Species", "v.quiz_score_dead_spp"],
          ["Substitute Only?", "v.substitute_only"],
          ["Widthdrawn", "v.widthdrawn"],
          ["Widthdrawn Date", "v.widthdrawn_date"],
          ["Widthdrawn Reason", "v.widthdrawn_reason"],
          ["Inactive Date", "v.inactive_date"],
          ["Kit Type", "v.kit_type"],
          ["Kit Return Date", "v.kit_return_date"],
          ["Deposit Amount", "v.deposit_amount"],
          ["Deposit Type", "v.deposit_type"],
          ["Deposit Check Number", "v.deposit_check_number"],
          ["Deposit Return Date", "v.deposit_return_date"],
          ["Deposit Return Type", "v.deposit_return_type"],
          ["Donor?", "v.donor"],
          ["Mailing List?", "v.mailing_list"],
          ["Mailing List Expiration", "v.mailing_list_expiration"],
          ["Directory?", "v.directory"],
          ["Directory: Phone?", "v.directory_phone"],
          ["Directory: Email?", "v.directory_email"],
          ["Directory: Guest?", "v.directory_guest"],
          ["Directory: Substitute?", "v.directory_substitute"],
          ["Notes on Volunteer", "v.notes"],
          ["Last Surveyed Date", "v.last_surveyed_date"],
          ["Last Surveyed Beach", "last_beach[v.id]"],
    ]

    output_csv = FasterCSV.generate do |csv|
      # Output header to CSV
      csv << table_map.map {|t| t[0]}

      volunteers.each do |v|
        vid = v.id.to_i
        values = []
        table_map.map do |t|
          begin
            val = eval(t[1])
          rescue
            logger.info("recieved an exception with #{t[0]}")
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

    send_data output_csv, :type => "text/plain",
      :filename => "volunteers.csv",
      :disposition => 'attachment'
  end

  def export_stats
    volunteer_query = "SELECT * FROM volunteers ORDER BY last_name;"
    volunteers = Volunteer.find_by_sql(volunteer_query)

    if volunteers.size == 0
      flash[:notice] = "No volunteers found in given date range."
      return
    end

    # queries pulled out of the volunteer_bird_surveys view
    query_map = [
      ['birds', "select volunteer_id, count(*) FROM volunteer_bird_surveys
        WHERE is_bird is TRUE GROUP BY volunteer_id"],
      ['finds', "select volunteer_id, count(*) FROM volunteer_bird_surveys
        WHERE is_bird is TRUE AND refound is FALSE GROUP BY volunteer_id"],
      ['families', "select volunteer_id, count(distinct(foot_type_family_id))
        FROM volunteer_bird_surveys where refound is false and is_bird is true and
        verified is true group by volunteer_id"],
      ['species', "select volunteer_id, count(distinct(species_id))
        FROM volunteer_bird_surveys where refound is false and is_bird is true and
        verified is true group by volunteer_id"],
      ['duration', "select volunteer_id, sum(duration) as count
      FROM survey_volunteers sv LEFT JOIN surveys s ON sv.survey_id = s.id
      WHERE role = 'data collector' group by volunteer_id"],
    ]
    birds = {}
    finds = {}
    families = {}
    species = {}
    duration = {}

    query_map.each do |q|
      res = Survey.connection.execute(q[1])
      eval("res.map {|r| #{q[0]}[r['volunteer_id'].to_i] = r['count'].to_i}")
    end

    date_region = {}
    date_region_query = "select volunteer_id, min(survey_date), max(survey_date),
      min(r.name) AS name,  max(be.name) AS beach_name, COUNT(*) AS survey_count
      FROM surveys s
      LEFT JOIN survey_volunteers sv ON sv.survey_id = s.id
      LEFT JOIN beaches be ON s.beach_id = be.id
      LEFT JOIN regions r ON be.region_id = r.id
      WHERE role = 'data collector'
      GROUP by volunteer_id"
    date_region_res = Survey.connection.execute(date_region_query)
    date_region_res.each do |r|
      vid = r['volunteer_id'].to_i
      date_region[vid] = {}
      date_region[vid]['min'] = r['min']
      date_region[vid]['max'] = r['max']
      date_region[vid]['name'] = r['name']
      date_region[vid]['surveys'] = r['survey_count']
    end

    # pull out the last surveyed beach name
    last_surveyed_beach_query = "SELECT volunteer_id,
        max(survey_date) as survey_date,
        max(be.name) AS beach_name
      FROM surveys s
      LEFT JOIN survey_volunteers sv ON sv.survey_id = s.id
      LEFT JOIN beaches be ON s.beach_id = be.id
      WHERE role = 'data collector'
      GROUP by volunteer_id"
    last_surveyed_res = Survey.connection.execute(last_surveyed_beach_query)
    last_surveyed_res.each do |r|
       vid = r['volunteer_id'].to_i
       date_region[vid]['last_beach_name'] = r['beach_name']
    end

    table_map = [
          ["Id", "v.id"],
          ["First Name", "v.first_name"],
          ["Middle Initial", "v.middle_initial"],
          ["Last Name", "v.last_name"],
          ["Birds, All Years", "birds[vid]"],
          ["Finds, All Years", "finds[vid]"],
          ["Families, All Years", "families[vid]"],
          ["Species, All Years", "species[vid]"],
          ["Surveys, All Years", "date_region[vid]['surveys']"],
          ["Survey Minutes, All Years", "duration[vid]"],
          ["First Survey Date", "date_region[vid]['min']"],
          ["Last Survey Date", "date_region[vid]['max']"],
          ["Last Surveyed Beach", "date_region[vid]['last_beach_name']"],
          ["Region", "date_region[vid]['name']"],
    ]

    output_csv = FasterCSV.generate do |csv|
      # Output header to CSV
      csv << table_map.map {|t| t[0]}

      volunteers.each do |v|
        vid = v.id.to_i
        values = []
        table_map.map do |t|
          begin
            val = eval(t[1])
          rescue
            #logger.info("recieved an exception with #{t[0]}")
          end
          values << val
        end
        csv << values
      end
    end

    send_data output_csv, :type => "text/plain",
      :filename => "volunteer_statistics.csv",
      :disposition => 'attachment'
  end

  def joins_for_collection
    #[:occupations, :involvements]
  end

  def directory
    @volunteers = Volunteer.find(:all,
                    :conditions => 'active is TRUE and directory IS TRUE',
                    :order => 'last_name ASC')
  end

end
