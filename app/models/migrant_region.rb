# == Schema Information
#
#  id   :integer       not null, primary key
#  code :string(255)   not null
#  name :string(255)   not null
#

# this isn't normalized, but may be fine since we're only using one
class MigrantRegion < ActiveRecord::Base
  has_many :regions
  #has_many :migrant_species
  has_many :species, :through => :migrant_species

  validates_presence_of :code, :name

  def before_validation
    self.code = code.upcase
  end
end
