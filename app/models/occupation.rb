# == Schema Information
#
#  id       :integer       not null, primary key
#  name     :string(255)   not null

class Occupation < ActiveRecord::Base

  has_and_belongs_to_many :volunteers, :join_table => :volunteer_occupation

end
