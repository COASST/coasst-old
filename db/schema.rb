# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 58) do

  create_table "ages", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "beaches", :force => true do |t|
    t.integer  "region_id"
    t.integer  "county_id"
    t.integer  "state_id"
    t.string   "code",              :limit => 10,                                                   :null => false
    t.string   "name",              :limit => 50,                                                   :null => false
    t.text     "description"
    t.text     "start_description"
    t.text     "turn_description"
    t.string   "city",              :limit => 50
    t.decimal  "latitude",                        :precision => 12, :scale => 8
    t.decimal  "longitude",                       :precision => 13, :scale => 8
    t.decimal  "turn_latitude",                   :precision => 12, :scale => 8
    t.decimal  "turn_longitude",                  :precision => 13, :scale => 8
    t.text     "location_notes"
    t.decimal  "length",                          :precision => 7,  :scale => 5
    t.string   "width",             :limit => 10
    t.string   "substrate",         :limit => 20
    t.string   "orientation",       :limit => 10
    t.boolean  "monitored",                                                      :default => true
    t.string   "access"
    t.string   "ownership"
    t.string   "geomorphology"
    t.boolean  "vehicles_allowed",                                               :default => false
    t.integer  "vehicles_start"
    t.integer  "vehicles_end"
    t.boolean  "dogs_allowed",                                                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "beaches", ["county_id"], :name => "beaches_county_idx"
  add_index "beaches", ["region_id"], :name => "beaches_region_idx"

  create_table "birds", :force => true do |t|
    t.integer  "survey_id",                                                                     :null => false
    t.integer  "species_id"
    t.integer  "group_id"
    t.integer  "subgroup_id"
    t.integer  "foot_type_family_id"
    t.integer  "plumage_id"
    t.integer  "age_id"
    t.string   "code"
    t.string   "where_found"
    t.boolean  "refound"
    t.boolean  "collected"
    t.text     "collected_comment"
    t.integer  "photo_count"
    t.string   "foot_condition"
    t.boolean  "intact"
    t.boolean  "head"
    t.boolean  "breast"
    t.string   "eyes"
    t.string   "feet"
    t.string   "wings"
    t.string   "entangled"
    t.text     "entangled_comment"
    t.boolean  "oil"
    t.text     "oil_comment"
    t.string   "sex"
    t.decimal  "bill_length",                  :precision => 8, :scale => 2
    t.decimal  "wing_length",                  :precision => 8, :scale => 2
    t.decimal  "tarsus_length",                :precision => 8, :scale => 2
    t.string   "tie_location"
    t.text     "tie_location_comment"
    t.string   "tie_number"
    t.integer  "tie_color_closest"
    t.integer  "tie_color_middle"
    t.integer  "tie_color_farthest"
    t.boolean  "is_bird",                                                    :default => true
    t.text     "comment"
    t.text     "verification_comment"
    t.boolean  "verified",                                                   :default => false
    t.string   "verification_method"
    t.text     "original_data"
    t.string   "identification_level"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "tie_other"
    t.string   "identification_level_family"
    t.string   "identification_level_species"
    t.string   "identification_level_group"
    t.string   "identification_trump"
  end

  add_index "birds", ["survey_id"], :name => "bird_survey_id_idx"
  add_index "birds", ["entangled", "refound", "verified"], :name => "birds_entangled_refound_verified"
  add_index "birds", ["oil", "refound", "verified"], :name => "birds_oil_refound_verified"
  add_index "birds", ["oil", "refound", "verified"], :name => "birds_oil_refound_verified_idx"
  add_index "birds", ["refound"], :name => "birds_refound_idx"
  add_index "birds", ["refound", "species_id"], :name => "birds_refound_species"
  add_index "birds", ["refound", "species_id"], :name => "birds_refound_species_idx"
  add_index "birds", ["species_id", "group_id"], :name => "birds_species_group"
  add_index "birds", ["species_id", "group_id"], :name => "birds_species_group_idx"

  create_table "concerned_species", :id => false, :force => true do |t|
    t.integer "concern_id"
    t.integer "species_id"
  end

  create_table "concerns", :force => true do |t|
    t.integer "state_id"
    t.string  "code",     :limit => 5
    t.string  "name",                  :null => false
  end

  create_table "counties", :force => true do |t|
    t.integer "state_id"
    t.string  "name",                           :null => false
    t.string  "division", :default => "county"
  end

  create_table "export_surveys", :id => false, :force => true do |t|
    t.float   "survey_day"
    t.float   "survey_month"
    t.float   "survey_year"
    t.date    "survey_date"
    t.integer "survey_id"
    t.string  "survey_code",                  :limit => 17
    t.integer "bird_code"
    t.string  "region"
    t.string  "beach_name",                   :limit => 50
    t.decimal "beach_length",                               :precision => 7, :scale => 5
    t.text    "survey_start_time"
    t.text    "survey_end_time"
    t.boolean "is_survey"
    t.string  "project"
    t.integer "duration"
    t.string  "weather"
    t.boolean "oil_present"
    t.string  "oil_frequency"
    t.boolean "oil_sheen"
    t.boolean "oil_tarballs"
    t.boolean "oil_goopy"
    t.boolean "oil_mousse"
    t.text    "survey_oil_comment"
    t.boolean "wood_present"
    t.string  "wood_size"
    t.string  "wood_continuity"
    t.string  "wood_zone"
    t.boolean "wrack_present"
    t.string  "wrack_width"
    t.string  "wrack_continuity"
    t.boolean "verified"
    t.string  "substrate",                    :limit => 20
    t.string  "orientation",                  :limit => 10
    t.text    "survey_comments"
    t.boolean "bird_verified"
    t.boolean "bird_refound"
    t.string  "bird_where_found"
    t.string  "foot_condition"
    t.string  "eyes"
    t.boolean "intact"
    t.boolean "head_present"
    t.boolean "breast_present"
    t.string  "feet"
    t.string  "wings"
    t.string  "entangled"
    t.text    "entangled_comment"
    t.boolean "oil"
    t.text    "oil_comment"
    t.string  "sex"
    t.boolean "collected"
    t.text    "collected_comment"
    t.integer "photo_count"
    t.string  "tie_location"
    t.text    "tie_location_comment"
    t.string  "tie_number"
    t.boolean "is_bird"
    t.text    "comment"
    t.text    "verification_comment"
    t.string  "identification_level"
    t.string  "identification_level_species"
    t.string  "identification_level_family"
    t.string  "identification_level_group"
    t.string  "tie_other"
    t.string  "species_name"
    t.string  "group_name"
    t.string  "subgroup_name"
    t.string  "age"
    t.string  "plumage"
    t.decimal "bill_length",                                :precision => 8, :scale => 2
    t.decimal "wing_length",                                :precision => 8, :scale => 2
    t.decimal "tarsus_length",                              :precision => 8, :scale => 2
  end

  add_index "export_surveys", ["survey_date"], :name => "export_surveys_survey_date_idx"

  create_table "foot_type_families", :force => true do |t|
    t.integer "toe_type_id",                   :null => false
    t.string  "name",                          :null => false
    t.string  "description"
    t.boolean "active",      :default => true
  end

  create_table "groups", :force => true do |t|
    t.integer "foot_type_family_id",                                 :null => false
    t.string  "name",                                                :null => false
    t.string  "code",                :limit => 5,                    :null => false
    t.boolean "active",                           :default => true
    t.string  "description"
    t.boolean "composite",                        :default => false
  end

  create_table "involvements", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "updated_at"
  end

  create_table "migrant_regions", :force => true do |t|
    t.string "code", :null => false
    t.string "name", :null => false
  end

  create_table "migrant_species", :force => true do |t|
    t.integer "species_id",                               :null => false
    t.integer "migrant_region_id",                        :null => false
    t.text    "status",            :default => "unknown"
  end

  create_table "occupations", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "updated_at"
  end

  create_table "plugin_schema_info", :id => false, :force => true do |t|
    t.string  "plugin_name"
    t.integer "version"
  end

  create_table "plumages", :force => true do |t|
    t.string  "name",                                       :null => false
    t.string  "code",       :limit => 2,                    :null => false
    t.boolean "admin_only",              :default => false, :null => false
  end

  create_table "regions", :force => true do |t|
    t.integer "state_id"
    t.string  "code",              :limit => 5
    t.string  "name",                           :null => false
    t.integer "migrant_region_id"
  end

  create_table "rights", :force => true do |t|
    t.string "name"
    t.string "controller"
    t.string "action"
  end

  create_table "rights_roles", :id => false, :force => true do |t|
    t.integer "right_id"
    t.integer "role_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_volunteers", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "volunteer_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "species", :force => true do |t|
    t.integer "foot_type_family_id",                    :null => false
    t.integer "group_id",                               :null => false
    t.integer "subgroup_id"
    t.string  "code",                                   :null => false
    t.string  "name",                                   :null => false
    t.boolean "sex_difference",      :default => false
    t.integer "tarsus_min",          :default => 0,     :null => false
    t.integer "tarsus_max",          :default => 999,   :null => false
    t.integer "wing_min",            :default => 0,     :null => false
    t.integer "wing_max",            :default => 999,   :null => false
    t.integer "bill_min",            :default => 0,     :null => false
    t.integer "bill_max",            :default => 999,   :null => false
    t.boolean "active",              :default => true
    t.string  "verification_source"
  end

  create_table "species_ages", :force => true do |t|
    t.integer "species_id",                    :null => false
    t.integer "age_id",                        :null => false
    t.boolean "admin_only", :default => false, :null => false
  end

  create_table "species_plumages", :force => true do |t|
    t.integer "species_id",                    :null => false
    t.integer "plumage_id",                    :null => false
    t.boolean "admin_only", :default => false, :null => false
  end

  create_table "states", :force => true do |t|
    t.string "prefix", :limit => 2, :null => false
    t.string "name",                :null => false
  end

  create_table "subgroups", :force => true do |t|
    t.integer "group_id", :null => false
    t.string  "name",     :null => false
  end

  create_table "survey_processings", :force => true do |t|
  end

  create_table "survey_tracks", :force => true do |t|
    t.integer "survey_id",                                   :null => false
    t.string  "track_type", :limit => 12,                    :null => false
    t.boolean "present",                  :default => false, :null => false
    t.integer "count"
  end

  add_index "survey_tracks", ["survey_id"], :name => "survey_tracks_survey_id_idx"

  create_table "survey_volunteer_processings", :force => true do |t|
  end

  create_table "survey_volunteers", :force => true do |t|
    t.integer "survey_id",                  :null => false
    t.integer "volunteer_id",               :null => false
    t.integer "travel_time"
    t.string  "role",         :limit => 20
  end

  add_index "survey_volunteers", ["volunteer_id"], :name => "survey_volunteers_volunteer_id_idx"

  create_table "surveys", :force => true do |t|
    t.integer  "beach_id",                                          :null => false
    t.string   "code",             :limit => 17,                    :null => false
    t.date     "survey_date",                                       :null => false
    t.time     "start_time",                                        :null => false
    t.time     "end_time",                                          :null => false
    t.integer  "duration"
    t.string   "weather"
    t.boolean  "oil_present"
    t.string   "oil_frequency"
    t.boolean  "oil_sheen"
    t.boolean  "oil_tarballs"
    t.boolean  "oil_goopy"
    t.boolean  "oil_mousse"
    t.text     "oil_comment"
    t.boolean  "wood_present"
    t.string   "wood_size"
    t.string   "wood_continuity"
    t.string   "wood_zone"
    t.boolean  "wrack_present"
    t.string   "wrack_width"
    t.string   "wrack_continuity"
    t.boolean  "tracks_present"
    t.text     "comments"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.boolean  "verified"
    t.boolean  "is_survey",                      :default => true
    t.boolean  "is_complete",                    :default => false
    t.string   "project"
  end

  add_index "surveys", ["beach_id"], :name => "survey_beach_idx"
  add_index "surveys", ["beach_id", "project"], :name => "survey_beach_project"
  add_index "surveys", ["beach_id", "project"], :name => "survey_beach_project_idx"
  add_index "surveys", ["beach_id", "verified"], :name => "survey_beach_verified"
  add_index "surveys", ["beach_id", "verified"], :name => "survey_beach_verified_idx"
  add_index "surveys", ["survey_date"], :name => "survey_date_idx"

  create_table "toe_types", :force => true do |t|
    t.string  "code",   :limit => 5,                    :null => false
    t.string  "name",   :limit => 20,                   :null => false
    t.boolean "active",               :default => true
  end

  create_table "volunteer_beaches", :force => true do |t|
    t.integer "beach_id",     :null => false
    t.integer "volunteer_id", :null => false
    t.integer "frequency"
  end

  create_table "volunteer_friends", :force => true do |t|
    t.integer "volunteer_id", :null => false
    t.integer "friend_id",    :null => false
    t.integer "frequency"
  end

  create_table "volunteer_involvement", :id => false, :force => true do |t|
    t.integer "volunteer_id",   :null => false
    t.integer "involvement_id", :null => false
  end

  create_table "volunteer_occupation", :id => false, :force => true do |t|
    t.integer "volunteer_id",  :null => false
    t.integer "occupation_id", :null => false
  end

  create_table "volunteers", :force => true do |t|
    t.integer  "state_id"
    t.string   "first_name",                                                                               :null => false
    t.string   "last_name",                                                                                :null => false
    t.string   "middle_initial",            :limit => 1
    t.string   "fullname"
    t.string   "email"
    t.string   "phone"
    t.string   "extension"
    t.string   "street_address"
    t.string   "city"
    t.string   "zip"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.datetime "ended_on"
    t.boolean  "active",                                                                :default => true
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "reset_password_code"
    t.datetime "reset_password_code_until"
    t.boolean  "has_account",                                                           :default => false
    t.string   "gender"
    t.integer  "trained_age"
    t.string   "occupation"
    t.string   "employer"
    t.string   "nickname"
    t.string   "contact_time_of_day"
    t.string   "contact_method"
    t.date     "trained_date"
    t.string   "find_us"
    t.string   "find_us_category"
    t.string   "involvement"
    t.string   "birding_experience"
    t.text     "volunteer_comments"
    t.string   "organizations"
    t.integer  "quiz_score_live_family"
    t.integer  "quiz_score_live_spp"
    t.integer  "quiz_score_dead_family"
    t.integer  "quiz_score_dead_spp"
    t.boolean  "substitute_only",                                                       :default => false
    t.boolean  "widthdrawn",                                                            :default => false
    t.date     "widthdrawn_date"
    t.string   "widthdrawn_reason"
    t.date     "inactive_date"
    t.string   "kit_type"
    t.date     "kit_return_date"
    t.decimal  "deposit_amount",                         :precision => 12, :scale => 8
    t.string   "deposit_type"
    t.string   "deposit_check_number"
    t.date     "deposit_return_date"
    t.string   "deposit_return_type"
    t.boolean  "donor",                                                                 :default => false
    t.boolean  "mailing_list"
    t.date     "mailing_list_expiration"
    t.boolean  "directory"
    t.boolean  "directory_phone"
    t.boolean  "directory_email"
    t.boolean  "directory_guest"
    t.boolean  "directory_substitute"
    t.text     "notes"
    t.date     "last_surveyed_date"
    t.boolean  "hazwoper_trained",                                                      :default => false
  end

  add_foreign_key "beaches", ["county_id"], "counties", ["id"], :name => "beaches_county_id_fkey"
  add_foreign_key "beaches", ["region_id"], "regions", ["id"], :name => "beaches_region_id_fkey"
  add_foreign_key "beaches", ["state_id"], "states", ["id"], :name => "beaches_state_id_fkey"

  add_foreign_key "birds", ["age_id"], "ages", ["id"], :name => "birds_age_id_fkey"
  add_foreign_key "birds", ["foot_type_family_id"], "foot_type_families", ["id"], :name => "birds_foot_type_family_id_fkey"
  add_foreign_key "birds", ["group_id"], "groups", ["id"], :name => "birds_group_id_fkey"
  add_foreign_key "birds", ["plumage_id"], "plumages", ["id"], :name => "birds_plumage_id_fkey"
  add_foreign_key "birds", ["species_id"], "species", ["id"], :name => "birds_species_id_fkey"
  add_foreign_key "birds", ["subgroup_id"], "subgroups", ["id"], :name => "birds_subgroup_id_fkey"
  add_foreign_key "birds", ["survey_id"], "surveys", ["id"], :name => "birds_survey_id_fkey"

  add_foreign_key "concerned_species", ["concern_id"], "concerns", ["id"], :name => "concerned_species_concern_id_fkey"
  add_foreign_key "concerned_species", ["species_id"], "species", ["id"], :name => "concerned_species_species_id_fkey"

  add_foreign_key "concerns", ["state_id"], "states", ["id"], :name => "concerns_state_id_fkey"

  add_foreign_key "counties", ["state_id"], "states", ["id"], :name => "counties_state_id_fkey"

  add_foreign_key "foot_type_families", ["toe_type_id"], "toe_types", ["id"], :name => "foot_type_families_toe_type_id_fkey"

  add_foreign_key "groups", ["foot_type_family_id"], "foot_type_families", ["id"], :name => "groups_foot_type_family_id_fkey"

  add_foreign_key "migrant_species", ["migrant_region_id"], "migrant_regions", ["id"], :name => "migrant_species_migrant_region_id_fkey"
  add_foreign_key "migrant_species", ["species_id"], "species", ["id"], :name => "migrant_species_species_id_fkey"

  add_foreign_key "regions", ["migrant_region_id"], "migrant_regions", ["id"], :name => "regions_migrant_region_id_fkey"
  add_foreign_key "regions", ["state_id"], "states", ["id"], :name => "regions_state_id_fkey"

  add_foreign_key "rights_roles", ["right_id"], "rights", ["id"], :name => "rights_roles_right_id_fkey"
  add_foreign_key "rights_roles", ["role_id"], "roles", ["id"], :name => "rights_roles_role_id_fkey"

  add_foreign_key "roles_volunteers", ["role_id"], "roles", ["id"], :name => "roles_volunteers_role_id_fkey"
  add_foreign_key "roles_volunteers", ["volunteer_id"], "volunteers", ["id"], :name => "roles_volunteers_volunteer_id_fkey"

  add_foreign_key "species", ["foot_type_family_id"], "foot_type_families", ["id"], :name => "species_foot_type_family_id_fkey"
  add_foreign_key "species", ["group_id"], "groups", ["id"], :name => "species_group_id_fkey"
  add_foreign_key "species", ["subgroup_id"], "subgroups", ["id"], :name => "species_subgroup_id_fkey"

  add_foreign_key "species_ages", ["age_id"], "ages", ["id"], :name => "species_ages_age_id_fkey"
  add_foreign_key "species_ages", ["species_id"], "species", ["id"], :name => "species_ages_species_id_fkey"

  add_foreign_key "species_plumages", ["plumage_id"], "plumages", ["id"], :name => "species_plumages_plumage_id_fkey"
  add_foreign_key "species_plumages", ["species_id"], "species", ["id"], :name => "species_plumages_species_id_fkey"

  add_foreign_key "subgroups", ["group_id"], "groups", ["id"], :name => "subgroups_group_id_fkey"

  add_foreign_key "survey_tracks", ["survey_id"], "surveys", ["id"], :name => "survey_tracks_survey_id_fkey"

  add_foreign_key "survey_volunteers", ["survey_id"], "surveys", ["id"], :name => "survey_volunteers_survey_id_fkey"
  add_foreign_key "survey_volunteers", ["volunteer_id"], "volunteers", ["id"], :name => "survey_volunteers_volunteer_id_fkey"

  add_foreign_key "surveys", ["beach_id"], "beaches", ["id"], :name => "surveys_beach_id_fkey"

  add_foreign_key "volunteer_beaches", ["beach_id"], "beaches", ["id"], :name => "volunteer_beaches_beach_id_fkey"
  add_foreign_key "volunteer_beaches", ["volunteer_id"], "volunteers", ["id"], :name => "volunteer_beaches_volunteer_id_fkey"

  add_foreign_key "volunteer_friends", ["friend_id"], "volunteers", ["id"], :name => "volunteer_friends_friend_id_fkey"
  add_foreign_key "volunteer_friends", ["volunteer_id"], "volunteers", ["id"], :name => "volunteer_friends_volunteer_id_fkey"

  add_foreign_key "volunteer_involvement", ["volunteer_id"], "volunteers", ["id"], :name => "volunteer_involvement_volunteer_id_fkey"
  add_foreign_key "volunteer_involvement", ["involvement_id"], "involvements", ["id"], :name => "volunteer_involvement_involvement_id_fkey"

  add_foreign_key "volunteer_occupation", ["volunteer_id"], "volunteers", ["id"], :name => "volunteer_occupation_volunteer_id_fkey"
  add_foreign_key "volunteer_occupation", ["occupation_id"], "occupations", ["id"], :name => "volunteer_occupation_occupation_id_fkey"

  add_foreign_key "volunteers", ["state_id"], "states", ["id"], :name => "volunteers_state_id_fkey"

end
