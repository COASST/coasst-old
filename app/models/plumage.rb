# == Schema Information
#
#  id         :integer       not null, primary key
#  name       :string(255)   not null
#  code       :string(2)     not null
#  admin_only :boolean       not null
#

class Plumage < ActiveRecord::Base
  has_many :birds
  has_many :species, :through => :species_plumages

  validates_presence_of   :name
  validates_length_of     :code, :in => 1..2
  validates_uniqueness_of :code

  def before_validation
    self.code = code.upcase
  end

  def self.by_species(species_id, role = 'volunteer')
    extra_sql = (role != 'admin') ? 'AND species_plumages.admin_only IS NOT true' : ''
    if not species_id.nil? and species_id.to_i > 0
      Plumage.find_by_sql(["SELECT plumages.* FROM plumages, species_plumages WHERE
                plumages.id = species_plumages.plumage_id AND
                species_plumages.species_id = ? #{extra_sql}",species_id])
    else
      []
    end
  end

  def to_label
    self.name.capitalize
  end

end
