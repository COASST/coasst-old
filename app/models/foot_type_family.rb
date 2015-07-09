# == Schema Information
#
#  id          :integer       not null, primary key
#  toe_type_id :integer       not null
#  name        :string(255)   not null
#  description :string(255)
#  active      :boolean       default(TRUE)
#

class FootTypeFamily < ActiveRecord::Base
  belongs_to :toe_type
  has_many :groups
  has_many :species
  has_many :subgroups, :through => :groups

  UNKNOWN_ID = 16
  FEET_MISSING_ID = 19

  validates_presence_of :name, :toe_type_id
  validates_uniqueness_of :description, :if => :description

  def known?
    if id == UNKNOWN_ID or id.nil? or id == 0 or id == FEET_MISSING_ID
      return false
    else
      return true
    end
  end

  def before_validation
    self.name = name.titlecase
  end

end
