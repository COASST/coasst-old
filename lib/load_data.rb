class LoadData < ActiveRecord::Migration

  extend DataLoader

  load_data "states"
  load_data "regions"
  load_data "counties"
  load_data "beaches"
  load_data "toe_types"
  load_data "migrant_regions"
  load_data "update_regions"
  load_data "ages"
  load_data "plumages"
  load_data "foot_type_families"
  load_data "groups"
  load_data "subgroups"
  load_data "species"
  load_data "migrant_species"
  load_data "volunteers"
  load_data "surveys"
  load_data "survey_volunteers"
  load_data "survey_tracks"
  load_data "birds"
  load_data "species_ages"
  load_data "species_plumages"
end
