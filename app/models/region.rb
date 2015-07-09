# == Schema Information
#
#  id                :integer       not null, primary key
#  state_id          :integer
#  code              :string(5)
#  name              :string(255)   not null
#  migrant_region_id :integer
#

class Region < ActiveRecord::Base

  has_many :beaches do
    def active_beaches
      find :all, :conditions
    end
  end
  belongs_to :migrant_region
  belongs_to :state

  # there must be a less stupid way of doing this...
  def self.find_active_regions
    active = []
    all = find(:all)
    all.each do |r|
      if r.beaches.count:
        active.push(r)
      end
    end
    active
  end

  validates_presence_of :code, :name, :state_id, :migrant_region_id
  validates_uniqueness_of :code, :name
  validates_length_of :code, :in =>1..5

  def before_validation
    self.code = code.upcase
  end


end
