class AddExperimentalMarineDebris < ActiveRecord::Migration
  def self.up

    # update surveys table for marine debris
    add_column :surveys, :sky, :text
    add_column :surveys, :wind, :text

    # new tables specific to marine debris
    #

    # transect specifics
    create_table :small_transects do |t|
      t.column :transect_number,  :string
      t.column :random_number,    :string
      t.column :start_time,       :time, :null => false
      t.column :end_time,         :time, :null => false
      t.column :substrate,    :text
    end

    create_table :medium_transects do |t|
      t.column :transect_number,  :string
      t.column :start_time,       :time, :null => false
      t.column :end_time,         :time, :null => false
    end

    create_table :large_transects do |t|
      t.column :transect_number,  :string
      t.column :start_time,       :time, :null => false
      t.column :end_time,         :time, :null => false
    end

    # automatically creating arrays is supported in rails 4, but not here --
    # have to manually create the arrays.
    execute("ALTER TABLE small_transects ADD zones_present TEXT[]");
    execute("ALTER TABLE small_transects ADD zones_widths NUMERIC(8, 3)[]");
    execute("ALTER TABLE medium_transects ADD zones_present TEXT[]");
    execute("ALTER TABLE medium_transects ADD zones_widths NUMERIC(8, 3)[]");
    execute("ALTER TABLE large_transects ADD zones_present TEXT[]");
    execute("ALTER TABLE large_transects ADD zones_widths NUMERIC(8, 3)[]");

    # small surveys contain multiple transects.
    create_table :quadrats do |t|
      t.column :small_transect_id,      :integer, :null => false
      t.column :quadrat_number,   :integer, :null => false
      t.column :zone,             :text, :null => false
    end

    create_table :object_taxons do |t|
      t.column :volunteer_id, :integer, :null => false
      t.column :name,     :text
      t.column :notes,    :text
      t.column :size,     :text
      t.column :material, :text
      t.column :is_complex, :boolean
      t.column :diameter, :decimal
      t.column :dimensions, :text
      t.column :openings, :integer
      t.column :created_on,       :datetime
      t.column :updated_on,       :datetime
    end

    create_table :debris do |t|
      t.column :small_transect_id, :integer
      t.column :medium_transect_id, :integer
      t.column :large_transect_id, :integer
      t.column :quadrat_id,     :integer
      t.column :zone,           :text
      t.column :count,          :integer
      t.column :object_number,  :integer
      t.column :object_taxon_id, :integer
      t.column :object_name,    :text
      t.column :size,           :text
      t.column :is_complex,     :boolean
      t.column :condition,      :text
      t.column :weathering,     :text
      t.column :material,       :text
      t.column :plastic,        :text
      t.column :color,          :text
      t.column :is_sharp,       :boolean
      t.column :is_crumbly,     :boolean
      t.column :is_shiny,       :boolean
      t.column :has_biofouling, :boolean
      t.column :has_bitemarks,  :boolean
      t.column :has_brand,      :boolean
      t.column :has_barcode,    :boolean
      t.column :language,       :text
      t.column :language_other, :text
      t.column :has_loops,      :boolean
      t.column :diameter,       :decimal
      t.column :dimensions,     :text
      t.column :flexibility,    :text
      t.column :is_hollow,      :boolean
      t.column :openings,       :integer
      t.column :sizes,          :text
    end

    # volunteer attributes necessary for debris surveying
    add_column :volunteers, :paces_per_10m, :integer

    # VOLUNTEER MANAGEMENT UPDATES
    #

    add_column :volunteers, :participate_as_job, :boolean
    add_column :volunteers, :mailing_list_debris, :boolean
    add_column :volunteers, :mailing_list_debris_expiration, :date

    create_table :responses do |t|
      t.column :type, :string, :null => false
    end

    create_table :volunteer_responses, :id => false do |t|
      t.column :volunteer_id, :integer
      t.column :response_id, :integer
    end

    # TODO needs to be specified
    create_table :projects do |t|
      t.column :name, :text
      t.column :description, :text
    end

    # TODO other attributes we're missing
    create_table :social_surveys do |t|
      t.column :project_id, :integer
      t.column :type, :string # pre-training, post-training, annual survey
      t.column :date, :datetime
    end

    # TODO this needs refining
    create_table :volunteer_social_surveys do |t|
      t.column :social_survey_id, :integer
      t.column :volunteer_id, :integer
      t.column :response_x, :string
    end

    create_table :events do |t|
      t.column :name, :string, :null => false
      t.column :description, :string
      t.column :location, :string     # is this necessary?
      t.column :state_id, :integer   # location of training
      t.column :county_id, :integer  # "
      t.column :date, :datetime
      t.column :type, :string # research, outreach, outreach: social, ...
      t.column :attendee_count, :integer # may have others attending such as potenital volunteers
      t.column :created_on,       :datetime
      t.column :updated_on,       :datetime
    end

    # TODO not clear this is necessary for organized categories / subcategories.
    #      stuck to a single text field for now.
    #create table :event_types do |t|
    #  t.column :category, :string # research, training, outreach, 
    #end

    # the event has both staff who put it on, and volunteers who attended
    create_table :volunteer_events do |t|
      t.column :volunteer_id, :integer
      t.column :event_id, :integer
      t.column :role, :string # attendee / presenter, ...
    end

    # materials -- what do they link to?
    create_table :materials do |t|
      t.column "type", :string, :null => false # MD protocol, BB protocol, field guide, ..
      t.column "version", :string, :null => false
    end

    create_table :volunteer_materials, :id => false do |t|
      t.column :volunteer_id, :integer, :null => false
      t.column :material_id, :integer, :null => false
    end

    # PHOTOS
    create_table :photos do |t|
      t.column :quality, :integer
      t.column :title, :string
      t.column :description, :string
      t.column :metadata, :string
      t.column :photo, :binary
      t.column :resource_uri, :string
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end

    create_table :photo_objects do |t|
      t.column :photo_id, :integer, :null => false
      t.column :type, :string # 'debris', 'bird', 'unknown'
      # should be linked to one of these types, or unknown.
      t.column :debris_id, :integer # unique observation, w/ time and pos
      t.column :survey_id, :integer # "      "
      t.column :bird_id, :integer
      t.column :species_id, :integer
    end

    # join tables
    #
    create_table :survey_transects, :id => false do |t|
      t.column :survey_id, :integer, :null => false
      t.column :small_transect_id, :integer
      t.column :medium_transect_id, :integer
      t.column :large_transect_id, :integer
    end

    create_table :transect_debris, :id => false do |t|
      t.column :small_transect_id, :integer
      t.column :medium_transect_id, :integer
      t.column :large_transect_id, :integer
      t.column :debris_id, :integer, :null => false
    end
  end

  def self.down
    # drop photo tables
    drop_table :photo_objects
    drop_table :photos

    # drop debris tables
    #
    drop_table :survey_transects
    drop_table :transect_debris
    drop_table :quadrats
    drop_table :small_transects
    drop_table :medium_transects
    drop_table :large_transects
    drop_table :debris
    drop_table :object_taxons

    # drop volunteer detail tables
    #
    drop_table :volunteer_responses
    drop_table :responses
    drop_table :social_surveys
    drop_table :volunteer_social_surveys
    drop_table :projects
    drop_table :volunteer_events
    drop_table :events
    drop_table :volunteer_materials
    drop_table :materials

    remove_column :surveys, :sky
    remove_column :surveys, :wind

    remove_column :volunteers, :paces_per_10m
    remove_column :volunteers, :participate_as_job
    remove_column :volunteers, :mailing_list_debris
    remove_column :volunteers, :mailing_list_debris_expiration
  end
end
