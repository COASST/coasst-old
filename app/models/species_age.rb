# == Schema Information
#
#  id                :integer       not null, primary key
#  species_id        :integer       not null
#  age_id            :integer       not null
#  status            :text          default("unknown")
#

class SpeciesAge < ActiveRecord::Base
  belongs_to :species
  belongs_to :age

  def to_label
    "#{species.name}"
  end
end
