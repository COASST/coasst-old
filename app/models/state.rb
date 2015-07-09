# == Schema Information
#
#  id     :integer       not null, primary key
#  prefix :string(2)     not null
#  name   :string(255)   not null
#

class State < ActiveRecord::Base
  has_many :beaches
  has_many :counties
  has_many :volunteers
  has_many :regions

  validates_presence_of :prefix, :name
  validates_uniqueness_of :prefix, :name
  validates_length_of :prefix, :is => 2

  # only a few states are actively used at this point,
  # no need to encumber the dropdown with all the US
  ValidStates = [
      'AK', 'CA', 'HI', 'OR', 'WA'
  ]

  def before_validation
    self.prefix = prefix.upcase
  end

  def self.current_states
    State.find(:all, :order => :name,
               :conditions => ['prefix IN (?)', ValidStates])
  end

  def self.all_states
    # volunteers may be in any state, provide a full list of states
    State.find(:all, :order => :name)
  end

  def to_label
    "State: #{self.name}"
  end
end
