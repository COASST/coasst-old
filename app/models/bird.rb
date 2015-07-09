# == Schema Information
#
#  id                   :integer       not null, primary key
#  survey_id            :integer       not null
#  species_id           :integer
#  group_id             :integer
#  subgroup_id          :integer
#  foot_type_family_id  :integer
#  plumage_id           :integer
#  age_id               :integer
#  code                 :string(255)
#  where_found          :string(255)
#  refound              :boolean
#  collected            :boolean
#  collected_comment    :text
#  photo_count          :integer
#  foot_condition       :string(255)
#  intact               :boolean
#  head                 :boolean
#  breast               :boolean
#  eyes                 :string(255)
#  feet                 :string(255)
#  wings                :string(255)
#  entangled            :string(255)
#  entangled_comment    :text
#  oil                  :boolean
#  oil_comment          :text
#  sex                  :string(255)
#  bill_length          :decimal(8, 2)
#  wing_length          :decimal(8, 2)
#  tarsus_length        :decimal(8, 2)
#  tie_location         :string(255)
#  tie_location_comment :text
#  tie_number           :integer
#  tie_color_closest    :integer
#  tie_color_middle     :integer
#  tie_color_farthest   :integer
#  is_bird              :boolean
#  comment              :text
#  verified             :boolean
#  verification_method  :string(255)
#  identification_level :string(255)
#  original_bird        :text
#  created_on           :datetime
#  updated_on           :datetime
#  tie_other            :string(255)
#

class Bird < ActiveRecord::Base

  before_validation :resolve_intact_fields!
  before_validation :resolve_classification!
  before_validation :resolve_ties!

  belongs_to :species   # a particular bird is a member of a species,
  belongs_to :subgroup
  belongs_to :group     # with its own group, age and plumage type
  belongs_to :foot_type_family
  belongs_to :age
  belongs_to :plumage
  belongs_to :survey    # parent survey bird was part of

  # ignore 'code' field: left-over composite key such as:  002AgateBch012201001

  # length attributes, values are attribute required to make possible
  # e.g. if head = true, then bill is a valid option.
  LengthAttributes = {
    'bill'   => ['head',  'false'],
    'wing'   => ['wings', 'Wings Missing'],
    'tarsus' => ['feet',  'Feet Missing'],
  }

  Head = [
    true,
    false
  ]

  Feet = [
    'Both Feet Present',
    'One Foot Present',
    'Feet Missing',
  ]

  Wings = [
    'Both Wings Present',
    'Left Wing Present',
    'Right Wing Present',
    'Wings Missing',
  ]

  Entangled = [
    ['Not Entangled',               'Not'],
    ['Net',                         'Net'],
    ['Fishing Line',                'Fishing Line'], # was Line
    ['Hook',                        'Hook'],
    ['Plastic',                     'Plastic'], # was 6-pack
    ['Other Man-Made Substance',    'Other Man-Made Substance'],
  ]

  Gender = [
    'Female',
    'Male',
    'Unknown',
  ]

  WhereFound = [
    ['High',        'High'],
    ['Wrack',       'Wrack'],
    ['Surfline',    'Surfline'],
    ['Not noted',   'Unknown'],
  ]

  Eyes = [
    ['Clear',        'Clear'],
    ['Sunk',         'Sunk'],
    ['Gone',         'Gone'],
    ['Head Missing', 'Head Missing'],
    ['Not noted',    'Unknown'],
  ]

  FootCondition = [
    ['Pliable',       'Pliable'],
    ['Stiff',         'Stiff'],
    ['Rotten',        'Rotten'],
    ['Feet Missing',  'Feet Missing'],
    ['Not noted',     'Unknown'],
  ]

  TieLocation = [
    # display       # in db
    [ 'Right Wing', 'Right Wing'],
    [ 'Left Wing',  'Left Wing' ],
    [ 'Leg',        'Leg'],
    [ 'Bill',       'Bill' ],
    [ 'Multiple',   'Multiple']
  ]

  TieColors = [
    ['No Cable Tie',nil],
    ['White (0)',0],
    ['Red (1)',1],
    ['Orange (2)',2],
    ['Yellow (3)',3],
    ['Dark Green (4)',4],
    ['Blue (5)',5],
    ['Gray (6)',6],
    ['Brown (7)',7],
    ['Purple (8)',8],
    ['Black (9)',9],
  ]

  VerificationMethods = [
    'Measurement & Photograph',
    'Measurement',
    'Photograph',
    'None'
  ]

  VerificationLevel = [
    'Correct',
    'Correct Unknown',
    'Timid',
    'Ambitious',
    'Incorrect',
    'Accuracy Unknown'
  ]

  # taxon unknowns, the unknown ids for the various taxon types
  TAXON_UNKNOWNS = {
    'species' =>          Species.find_by_name('Unknown'),
    'subgroup' =>         Subgroup.find_by_name('Unknown'),
    'group' =>            Group.find_by_name('Unknown'),
    'foot_type_family' => FootTypeFamily.find_by_name('Unknown'),
  }

  # keep taxon unknowns as a hash, and store ordering here
  TAXONS_ORDERED = ['species', 'subgroup', 'group', 'foot_type_family']

  validates_inclusion_of :where_found,    :in => WhereFound.map {|a| a[1]},
                         :message => 'must be selected'
  validates_inclusion_of :foot_condition, :in => FootCondition.map {|a| a[1]}
  validates_inclusion_of :eyes,           :in => Eyes.map {|a| a[1]}
  validates_inclusion_of :feet,           :in => Feet
  validates_inclusion_of :wings,          :in => Wings
  validates_inclusion_of :entangled,      :in => Entangled.map {|a| a[1]}
  validates_inclusion_of :sex,            :in => Gender, :if => Proc.new { |u| u.sex }
  # only require tie location if one of the tags is set
  validates_inclusion_of :tie_location,
                         :in => TieLocation.map {|a| a[1]},
                         :if => Proc.new { |u| !u.tie_color_closest.blank? ||
                                               !u.tie_color_middle.blank? ||
                                               !u.tie_color_farthest.blank? }
  validates_inclusion_of :tie_color_closest, :in => TieColors.map {|a| a[1]}
  validates_inclusion_of :tie_color_middle, :in => TieColors.map {|a| a[1]}
  validates_inclusion_of :tie_color_farthest, :in => TieColors.map {|a| a[1]}
  validates_inclusion_of :refound,
                         :collected,
                         :intact,
                         :head,
                         :breast,
                         :oil,
                         :in => [true, false]
  validates_numericality_of :photo_count
  # lengths only required when we have the relevant bird parts
  validates_numericality_of :bill_length,
                            :if => Proc.new { |u| u.head? and u.bill_length?}
  validates_numericality_of :wing_length,
                            :if => Proc.new { |u| u.wings != 'Wings Missing' and u.wing_length? }
  validates_numericality_of :tarsus_length,
                            :if => Proc.new { |u| u.feet != 'Feet Missing' and u.tarsus_length?}

  validates_presence_of  :survey_id, :species_id  # are these right?
  # plumage and age fields are only valid when the bird is an adult
  validates_presence_of  :plumage_id, :age_id, :if => Proc.new { |u| u.age_id == 1}
  validates_presence_of  :tie_location_comment,
                         :if => Proc.new { |u| u.tie_location == 'Multiple' },
                         :message => 'is required for multiple ties'

  # verifier validation
  validates_presence_of :verification_method,  :if => Proc.new { |u| u.verified? }
  validates_presence_of :identification_level_family, :if => Proc.new { |u| u.verified? }
  validates_presence_of :identification_level_species, :if => Proc.new { |u| u.verified? }
  validates_presence_of :identification_level_group, :if => Proc.new { |u| u.verified? }
  # is_bird verified verification_method, identification_level


  def validate
    if intact?
      errors.add_to_base("If intact is set, head must be set to 'Present'") if not head
      errors.add_to_base("If intact is set, breast must be set to  'Present'") if not breast
      errors.add_to_base("If intact is set, feet must be set to 'Both Feet Present'") if feet != "Both Feet Present"
      errors.add_to_base("If intact is set, wings must be set to 'Both Wings Present'") if wings != "Both Wings Present"
    end

    # ties
    errors.add_to_base("Must select at least one tie") if tie_number !~ /\d{1,3}/
    if tie_number?
      if [tie_color_closest, tie_color_middle, tie_color_farthest].join('') != tie_number
        errors.add_to_base("Tie number must match selection for individual ties")
      end
    end
    # if entangled or oiled are set, comment is required
    if entangled != 'Not'
      errors.add :entangled_comment, "required if bird was entangled" if entangled_comment.blank?
    end
    if oil?
      errors.add :oil_comment, "required if bird was oiled" if oil_comment.blank?
    end
    if collected?
      errors.add :collected_comment, 'required if bird was collected' if collected_comment.blank?
    end
    # Make sure lengths are all within range for the species given
    # e.g. if wing_min = 12, wing_max = 15, wing_length must be in this range
    # These aren't errors, are optional
    #LengthAttributes.each do |la|
    # if length_in_range(la) == false
    #   errors.add("#{length_name}_length","is out of the valid range for #{spp_attr['name'].titleize}")
    # end
    #end
  end

  def resolve_intact_fields!
    if self.intact?
      self.head = true
      self.breast = true
      self.feet = "Both Feet Present"
      self.wings = "Both Wings Present"
    end
    true
  end

  def length_in_range(length_name)
    if not self.species.nil?
      spp_attr = self.species.attributes
      length = self.attributes["#{length_name}_length"]
      # only bother if a value is set, otherwise numericality check will get it
      # and we don't want multiple error messages
      if not length.nil?
        length_range = spp_attr["#{length_name}_min"]..spp_attr["#{length_name}_max"]
        if length_range.include? length
          return true
        else
          return false
        end
      end
    end
    return nil
  end

  def self.total_by_year(type = "")
    years = {}
    tables = "birds, surveys"
    where_clause = "WHERE birds.survey_id=surveys.id " +
                 " AND birds.refound IS false "
                 #+ " AND (birds.species_id IS NOT NULL OR (birds.species_id IS NULL AND birds.group_id IS NULL))"

    if type == "beach"
      var_type = ", surveys.beach_id"
    else type == "species"
      var_type = ", birds.species_id"
    end

    sql_year = "EXTRACT(YEAR FROM surveys.survey_date)"
    counts = find_by_sql("SELECT #{sql_year} AS year#{var_type} AS id, count(*) AS cnt FROM #{tables} #{where_clause} GROUP BY #{sql_year}#{var_type}")
    counts.each do |c|
      if type.empty?
        years[c.year.to_i] = c.cnt_to_i
      else
        if not years.has_key?(c.year.to_i)
          years[c.year.to_i] = {}
        end
        years[c.year.to_i][c.id.to_i] = c.cnt.to_i
      end
    end
    years
  end

  def resolve_classification!
    logger.info("\n\nresolve_start: #{self.foot_type_family_id} #{self.species_id} #{self.group_id} #{self.subgroup_id}")
    if not foot_type_family_id.nil? and foot_type_family_id < 0
      if not group_id.nil? and group_id < 0
        # negative group = subgroup selected with composite group
        self.subgroup_id = -1 * group_id
        sg = Subgroup.find(self.subgroup_id)
        self.group_id = sg.group
        self.foot_type_family = sg.group.foot_type_family
      else
        if group_id.nil?
          self.subgroup_id = nil
        end
        self.group_id = -1 * foot_type_family_id
        g = Group.find(self.group_id)
        self.foot_type_family_id = g.foot_type_family_id
        return
      end
    end

    if species and species.known?
      self.subgroup = species.subgroup
      self.group = species.group
      self.foot_type_family = species.foot_type_family
    elsif subgroup and subgroup.known?
      if subgroup.group.foot_type_family.id == self.foot_type_family_id
        self.group = subgroup.group
        self.foot_type_family = group.foot_type_family
      else
        self.subgroup_id = nil
      end
    elsif group and group.known?
      self.foot_type_family = group.foot_type_family
    end
    logger.info("\n\nresolve_done: #{self.foot_type_family_id} #{self.species_id} #{self.group_id} #{self.subgroup_id}")
  end

  def resolve_ties!
    # when the volunteer enters a tie, they enter the components, so copy to the tie_number.
    # when the verifier enters a tie, they _only_ enter tie number, so do the reverse.
    if self.verified?
      self.tie_color_closest, self.tie_color_middle, self.tie_color_farthest = self.tie_number.split('').map {|l| l.to_i}
    else
      self.tie_number = [tie_color_closest, tie_color_middle, tie_color_farthest].join('')
    end
  end

  def self.carcass_count(condition = "")
    base = "birds.refound IS FALSE"
    #base = "refound IS false AND (species_id IS NOT NULL OR (species_id IS NULL AND group_id IS NULL))"
    if not condition.nil? and not condition.empty?
      base += " AND " + condition
    end
    if (condition =~ /surveys/)
      Bird.count(:conditions=>base, :include=>:survey)
    else
      Bird.count(:conditions=>base)
    end
  end

  def highest_taxon
    TAXONS_ORDERED.each do |t|
      taxon_id = "#{t}_id"
      # check the id itself, and against the unknowns; if these pass then
      # use the 'send' method to get back the full data from the model (generates another query)
      if !self[taxon_id].nil? and self[taxon_id] != TAXON_UNKNOWNS[t].id
        return self.send(t)
      end
    end
    # a couple of odd birds (pun intended) have no taxon information
    return TAXON_UNKNOWNS['foot_type_family']
  end

  def previous_find
    # for a refind to be counted, we want to check that the beach and cable tie match
    if self.refound == false or self.tie_number.nil?
      return nil
    end

    # find previous surveys on this same beach, with same tie,
    # grab the _latest_ one prior to the current survey

    conditions = "beach_id = ? AND birds.tie_number = ? " +
                 "AND surveys.id != ? AND surveys.survey_date < ? " +
                 "AND birds.verified IS TRUE"

    last_survey = Survey.find(:all, :conditions =>
          [conditions, self.survey.beach_id, self.tie_number,
                       self.survey.id, self.survey.survey_date],
          :include => :birds).sort_by {|s| s.survey_date}.last

    if last_survey.nil? or last_survey.birds.nil?
      nil
    else
      last_survey.birds.find_by_tie_number(self.tie_number)
    end
  end

  def serialize
    return self.to_yaml
  end

  def original_bird
    if not self.original_data.nil?
      return YAML::load(self.original_data)
    else
      return self
    end
  end

  def to_label
    "Species: #{self.species.name}"
  end

  protected
end
