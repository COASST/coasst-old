# == Schema Information
#
#  id                  :integer       not null, primary key
#  foot_type_family_id :integer       not null
#  group_id            :integer       not null
#  subgroup_id         :integer
#  code                :string(255)   not null
#  name                :string(255)   not null
#  sex_difference      :boolean
#  tarsus_min          :integer       default(0), not null
#  tarsus_max          :integer       default(999), not null
#  wing_min            :integer       default(0), not null
#  wing_max            :integer       default(999), not null
#  bill_min            :integer       default(0), not null
#  bill_max            :integer       default(999), not null
#  active              :boolean       default(TRUE)
#  verification_source :string(255)
#

class Species < ActiveRecord::Base

  UNKNOWN_ID = 114

  belongs_to :foot_type_family    # may be able to remove these:
  belongs_to :group               # can get ftf, group from subgroup
  belongs_to :subgroup
  has_many :birds
  has_many :migrant_species, :dependent => :destroy
  has_many :migrant_regions, :through => :migrant_species
  has_many :species_plumages, :dependent => :destroy
  has_many :plumages, :through => :species_plumages
  has_and_belongs_to_many :concerns, :join_table => :concerned_species
  has_many :species_ages, :dependent => :destroy
  has_many :ages, :through => :species_ages

  validates_length_of :code, :in => 4..5
  validates_uniqueness_of :code, :name
  validates_numericality_of :tarsus_min, :tarsus_max,
                         :wing_min, :wing_max,
                         :bill_min, :bill_max,
                         :greater_than_or_equal_to => 0,
                         :less_than_or_equal_to => 999
  validates_presence_of :foot_type_family_id
  validates_presence_of :subgroup_id
  validates_presence_of :group_id


  Measurements = [
  # measurement  units
    ["bill",     "mm"],
    ["wing",     "cm"],
    ["tarsus",   "mm"],
  ]

  # returns a hash of key.  key is species.id, value is cnt
  # grouping nils with id 114 (Unknown)
  def self.carcass_count_table(condition = "")
    tables = "birds"
    #where_clause = "WHERE birds.refound IS FALSE AND (birds.species_id IS NOT NULL OR (birds.species_id IS NULL AND birds.group_id IS NULL))"
    where_clause = "WHERE birds.refound IS FALSE AND birds.species_id IS NOT NULL"
    if condition =~ /surveys\./
      tables += " INNER JOIN surveys ON birds.survey_id=surveys.id"
    end

    if not condition.nil? and not condition.empty?
      where_clause += " AND "+condition
    end

    counts = Bird.find_by_sql("SELECT species_id, count(*) AS cnt FROM #{tables} #{where_clause} GROUP BY species_id")

    lookup_count = {}
    nil_count = 0
    for s in counts
      if s.species_id.nil?
        nil_count = s.cnt.to_i
      else
        lookup_count[s.species_id] = s.cnt.to_i
      end
    end

    if counts.length > 0
      if lookup_count.has_key?(UNKNOWN_ID)
        lookup_count[UNKNOWN_ID] += nil_count
      else
        lookup_count[UNKNOWN_ID] = nil_count
      end
    end

    species = Species.find_by_sql("SELECT id FROM species")

    #for s in species
    #  lookup_count[s.id] ||= 0
    #end

    # XXX FIXME: hack to prevent unknowns from statistics, need to fix it up
    lookup_count[UNKNOWN_ID] = 0
    lookup_count
  end

  def self.by_group(group_id)
    if not group_id.nil? and group_id.to_i > 0
      Species.find(:all,:conditions=>{:group_id=>group_id})
    else
      []
    end
  end

  def self.by_family(family_id)
    if not family_id.nil? and family_id.to_i > 0
      Species.find(:all,:conditions=>{:foot_type_family_id=>family_id})
    else
      []
    end
  end

  def self.sex(species_id, role = 'volunteer')
    list = []
    if not species_id.nil? and species_id.to_i > 0
      if Species.find(species_id).sex_difference or role == 'admin'
        list = Bird::Gender
      end
    end
    list
  end

  def known?
    if id == UNKNOWN_ID or id.nil? or id == 0
      return false
    else
      return true
    end
  end

  def length_in_range?(field,length)
    spp_attr = self.attributes
    # only bother if a value is set, otherwise numericality check will get it
    # and we don't want multiple error messages
    if not length.nil? and spp_attr.has_key? "#{field}_min"
      length = length.to_i
      return nil if length == 0
      length_range = spp_attr["#{field}_min"]..spp_attr["#{field}_max"]
      if length_range.include? length
        return true
      else
        return false
      end
    end
    return nil
  end

  def get_graph_data(start_date = Survey::Epoch)
    values = {}
    max_date = 0
    sql = "SELECT extract(days from
                     (survey_date + time '0:00') - '#{start_date}')
                   AS epoch_date, cnt
            FROM (
              SELECT COUNT(survey_date) AS cnt, survey_date
              FROM birds b LEFT JOIN surveys s ON s.id = b.survey_id
              WHERE b.refound IS FALSE AND b.species_id = ?
              GROUP BY survey_date ORDER BY survey_date
            ) AS species_by_date"
    Survey.find_by_sql([sql,self.id]).each { |row|
      date = row.epoch_date.to_i
      values[date] = row.cnt.to_i
      if max_date < date:
        max_date = date
      end
    }
    x = 1
    graph_data = {1 => 0}
    (1..2571).to_a.each { |i|
      if i >= x * 31:
        x += 1
        graph_data[x] = 0
      end

      if values[i]:
        graph_data[x] += values[i]
      end
    }

    graph_data.values
  end

  def to_s
    self.name
  end
end

class Float
  def truncate(places = 0)
    return to_s if places == 0
    sprintf( "%0.#{places}f", self)
  end
end
