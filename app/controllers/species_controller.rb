class SpeciesController < ApplicationController

  before_filter :find_year
  before_filter :check_authentication, :except => [:show]

  layout 'admin'

  active_scaffold :species do |config|

    # search configuration
    actions.exclude :search
    actions.add :live_search

    species_relations = {
      :group => 'groups.name',
      :subgroup => 'subgroups.name',
      :foot_type_family => 'foot_type_families.name',
    }
    species_relations.each do |sr, v|
      config.columns[sr].search_sql = v
      config.live_search.columns << sr
    end

    # link configuration
    delete.link.confirm = "Delete species?"
    show.link.page = true
    action_links.add 'export', :label => 'Export to CSV', :page => true

    # list options
    list.columns = [:name, :code, :group, :subgroup, :foot_type_family]
    list.per_page = 25
    config.list.sorting = { :name => :asc}

    # global columns configuration
    [:tarsus_min, :tarsus_max, :bill_min, :bill_max].each do |label|
      columns[label].label = columns[label].label.titleize + " (mm)"
    end

    [:wing_min, :wing_max].each do |label|
      columns[label].label = columns[label].label.titleize + " (cm)"
    end

    # attributes used in create & update
    base_columns = [:name, :code]
    identification = [:group, :subgroup, :foot_type_family]
    physical = [:sex_difference, :species_ages, :species_plumages, :tarsus_min, :tarsus_max,
                :wing_min, :wing_max, :bill_min, :bill_max]
    relations = [:concerns, :migrant_species]

    # creation options
    create.link.label = "Add new species"
    create.columns = base_columns

    create.columns.add_subgroup "Identification" do |id_group|
      id_group.add identification
    end

    create.columns.add_subgroup "Physical" do |phys_group|
      phys_group.add physical
    end

    create.columns.add_subgroup "Relations" do |rel_group|
      rel_group.add relations
    end

    # update options
    update.columns = base_columns

    update.columns.add_subgroup "Identification" do |id_group|
      id_group.add identification
    end

    update.columns.add_subgroup "Physical" do |phys_group|
      phys_group.add physical
    end

    update.columns.add_subgroup "Relations" do |rel_group|
      rel_group.add relations
    end

    # don't allow manipulation of these tables, just provide select list
    [:foot_type_family, :group, :subgroup, :concerns].each do |select|
      columns[select].form_ui = :select
    end

    # 2010.01.25 looks like this is licked, leaving below for reference
    #
    #
    # Almost got this working correctly, but we still need a way of rendering items from these
    # subforms, for example, we'll want to select not only the region, but also the 'status'
    # for migrant_regions: resident / migrant. I'm guessing this can be done in a reasonably
    # straightforward way, but if not, then do the nested subform thing.
    #   Pudget sound:    [ ] migrant [ ] resident (as radio buttons)
    # otherwise, it inserts as expected, but doesn't include the status correctly (set to 'unknown')

    # the form_ui = select doesn't work here! it generates insert statements which include the 
    # primary key for a join table, and is set incorrectly. we want it to generate someting like:
    # INSERT INTO species_ages (age_id, species_id) VALUES (6, 137) but instead it creates:
    # INSERT INTO species_ages (id, age_id, species_id) VALUES (6, 6, 137); which doesn't work on 
    #   account of their already being a species_age of 6 which its quite happy with, thank you very much.
    #
    #columns[:species_ages].form_ui = :nested
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def show
    @species = Species.find(params[:id])
    subselect = "SELECT COUNT(*) AS cnt,birds.survey_id FROM birds"
    subselect += " WHERE birds.refound IS FALSE AND birds.species_id=?"
    if params[:oiled] == "1"
      subselect += " AND birds.oil IS true AND birds.verified IS true "
    end
    if params[:entangled] == "1"
      subselect += " AND birds.entangled != 'Not' AND birds.verified IS true "
    end
    subselect += " GROUP BY birds.survey_id"
    #refinds OK? - refounds variable currently set to FALSE
    sql = "SELECT surveys.id, surveys.survey_date, surveys.beach_id,
                  beaches.name AS beach_name, s.cnt FROM surveys "
    sql += " INNER JOIN (#{subselect}) s ON s.survey_id=surveys.id"
    sql += " LEFT OUTER JOIN beaches ON beaches.id=surveys.beach_id"
    if not @year.nil?
      sql += " WHERE surveys.survey_date >= '#{@year}-01-01' AND "
      sql += "surveys.survey_date <  '#{@year+1}-01-01'"
    end

    @sql = sql
    @surveys = Survey.find_by_sql([sql,params[:id]])
    @bird_count = 0

    for s in @surveys
      @bird_count += s.cnt.to_i
    end
    render :layout => 'plain'
  end

  private

  def find_year
    if params[:year] =~ /^\d{4}$/
      @year = params[:year].to_i
    else
      @year = nil
    end
  end

end
