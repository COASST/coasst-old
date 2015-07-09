# == Schema Information
#
#  id       :integer       not null, primary key
#  state_id :integer
#  name     :string(255)   not null
#  division :string(255)   default("county")
#

class County < ActiveRecord::Base
  belongs_to :state
  has_many :beaches

  Types = [
    # Displayed    stored in db
    [ "Census Area",  "census area"],
    [ "Borough",      "borough"],
    [ "County",       "county"],
    [ "Unspecified",  nil]
  ]

  validates_presence_of :name, :state_id
  validates_inclusion_of :division, :in => Types.map {|disp, value| value}

  def before_validation
    self.name = name.titlecase
  end
end
