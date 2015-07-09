# == Schema Information
#
#  id                :integer       not null, primary key
#  species_id        :integer       not null
#  migrant_region_id :integer       not null
#  status            :text          default("unknown")
#

class MigrantSpecies < ActiveRecord::Base
  belongs_to :species
  belongs_to :migrant_region

  Status = [
    # Displayed    stored in db
    [ "Migrant",   "migrant"],
    [ "Resident",  "resident"],
    [ "Unknown",   "unknown"]
  ]

  validates_inclusion_of :status, :in => Status.map {|disp, value| value}

  def to_label
    "#{species.name}"
  end
end
