# == Schema Information
#
#  id                  :integer       not null, primary key
#  foot_type_family_id :integer       not null
#  name                :string(255)   not null
#  code                :string(5)     not null
#  active              :boolean       default(TRUE)
#  description         :string(255)
#  composite           :boolean
#

class Group < ActiveRecord::Base

  UNKNOWN_ID = 35

  belongs_to :foot_type_family
  has_many   :subgroups
  has_many   :species # may be frivolous, get through bird?
  has_many   :birds

  validates_presence_of :name, :code, :foot_type_family_id
  validates_uniqueness_of :code

  def before_validation
    self.name = name.titlecase
    self.code = code.upcase
  end

  def known?
    if id == UNKNOWN_ID or id.nil? or id == 0
      return false
    else
      return true
    end
  end

  def self.carcass_count_table(condition = "")
    tables = "birds, species LEFT JOIN groups ON species.group_id=groups.id"
    where_clause = "WHERE birds.species_id = species.id AND birds.species_id != #{Species::UNKNOWN_ID}"

    if not condition.nil? and not condition.empty?
      where_clause += " AND " + condition
    end

    sql = "SELECT species.group_id, count(*) AS cnt FROM #{tables} #{where_clause} GROUP BY species.group_id"
    counts = find_by_sql(sql)


    tables2 = "birds"
    where_clause2 = " WHERE (birds.species_id IS NULL OR birds.species_id = #{Species::UNKNOWN_ID})"
    if not condition.nil? and not condition.empty?
      where_clause2 += " AND " + condition
    end

    sql2 = "SELECT birds.group_id, count(*) AS cnt FROM #{tables2} #{where_clause2} GROUP BY birds.group_id"
    counts2 = find_by_sql(sql2)

    lookup_count = {}
    for s in counts
      lookup_count[s.group_id.to_i] = s.cnt.to_i
    end
    for s in counts2
      if lookup_count[s.group_id.to_i]
        lookup_count[s.group_id.to_i] += s.cnt.to_i
      else
        lookup_count[s.group_id.to_i] = s.cnt.to_i
      end
    end

    groups = find_by_sql("SELECT id FROM groups")
    for g in groups
      if not lookup_count.has_key?(g.id)
        lookup_count[g.id] = 0
      end
    end
    # Key 35 is "Unknown"
    nil_count = lookup_count[0]
    lookup_count.delete(0)
    lookup_count[UNKNOWN_ID] = nil_count
    lookup_count
  end

  def ranges
    select_attributes = []
    Bird::LengthAttributes.keys do |la|
      select_attributes << "MIN(#{la}_min) AS #{la}_min, MAX(#{la}_max) AS #{la}_max"
    end

    sql = "SELECT #{select_attributes.join(",")} FROM species WHERE group_id = #{self.id}"
    group_lengths = Group.find_by_sql(sql)[0].attributes

  end

end
