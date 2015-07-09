# == Schema Information
#
#  id         :integer       not null, primary key
#  species_id :integer       not null
#  plumage_id :integer       not null
#  admin_only :boolean       not null
#

class SpeciesPlumage < ActiveRecord::Base
  belongs_to :species
  belongs_to :plumage

  def to_label
    "#{species.name}"
  end
end
