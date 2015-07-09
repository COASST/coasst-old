# == Schema Information
#
#  id     :integer       not null, primary key
#  code   :string(5)     not null
#  name   :string(20)    not null
#  active :boolean       default(TRUE)
#

class ToeType < ActiveRecord::Base
  has_one :foot_type_family

  validates_presence_of :code, :name
  validates_uniqueness_of :code, :name

  validates_length_of :code, :maximum => 2
  validates_length_of :name, :maximum => 20

  def before_validation
    self.code = code.upcase
    self.name = name.titlecase
  end
end
