# == Schema Information
# Schema version: 31
#
# Table name: ages
#
#  id   :integer       not null, primary key
#  name :string(255)   not null
#
class Age < ActiveRecord::Base
  has_many :birds
  #has_many :species_ages
  has_many :species, :through => :species_ages
  # XXX temporary 2010.01.25
  #has_and_belongs_to_many :species, :join_table => :species_ages

  validates_presence_of :name
  validates_uniqueness_of :name, :if => Proc.new{ |a| !a.name.blank? }

  AgeTypes = [
   ['Adult',               'adult'],
   ['Immature',            'immature'],
   ['Immature (Juvenile)', 'juvenile'],
   ['Immature (Subadult)', 'subadult'],
   ['Unknown',             'unknown'],
  ]

  def self.by_species(species_id, role = 'volunteer')
    sorted = []
    extra_sql = (role != 'admin') ? " AND species_ages.admin_only IS false" : ''
    if not species_id.nil? and species_id.to_i > 0
      found = Age.find_by_sql(["SELECT ages.* FROM ages, species_ages " +
                      "WHERE ages.id = species_ages.age_id AND " +
                      "species_ages.species_id = ? #{extra_sql}",species_id])

      AgeTypes.each { |display, db|
        if found.map { |n|
          if n.name == db
            sorted.push(n)
          end
        }
        end
      }
    end
    sorted
  end

  def title
    text = ''
    AgeTypes.each { |display, db|
      if self.name == db
        text = display
      end
    }
    text
  end

  def to_label
    self.name.capitalize
  end

end
