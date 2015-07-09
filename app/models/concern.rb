# == Schema Information
#
#  id       :integer       not null, primary key
#  state_id :integer       
#  code     :string(5)     
#  name     :string(255)   not null
#

class Concern < ActiveRecord::Base

  has_and_belongs_to_many :species, :join_table => :concerned_species

end
