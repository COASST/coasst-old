# == Schema Information
#
#  id   :integer       not null, primary key
#  name :string(255)
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :volunteers
  has_and_belongs_to_many :rights

  def has_right_for?(action_name, controller_name)
    rights.detect{ |right| right.has_right_for?(action_name, controller_name)}
  end
end
