class AddVolunteerInvolvementOccupationData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "involvements"
    load_data "occupations"
    #load_data "volunteer_involvement"
    #load_data "volunteer_occupation"
  end

  def self.down
  end
end
