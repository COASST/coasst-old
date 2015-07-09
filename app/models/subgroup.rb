# == Schema Information
#
#  id       :integer       not null, primary key
#  group_id :integer       not null
#  name     :string(255)   not null
#

class Subgroup < ActiveRecord::Base
  belongs_to :group
  has_many   :species

  UNKNOWN_ID = 46

  validates_presence_of  :name
  validates_uniqueness_of :name, :if => Proc.new { |s| !s.name.blank? }

  def known?
    if id == UNKNOWN_ID or id.nil? or id == 0
      return false
    else
      return true
    end
  end

  def before_validation
    self.name = name.titlecase
  end
end
