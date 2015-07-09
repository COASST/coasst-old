# == Schema Information
#
#  id           :integer       not null, primary key
#  beach_id     :integer       not null
#  volunteer_id :integer       not null
#  frequency    :integer
#

class VolunteerBeach < ActiveRecord::Base
  belongs_to :volunteer
  belongs_to :beach

  def self.beach_exists(beach_id, volunteer_id)
    @volunteer_beach = VolunteerBeach.find(:all,
      :conditions => [ "volunteer_id = ? AND beach_id = ?",
        volunteer_id, beach_id]
    )
    if !@volunteer_beach.blank?
      true
    else
      false
    end
  end

end
