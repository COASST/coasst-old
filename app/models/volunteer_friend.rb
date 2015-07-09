# == Schema Information
#
#  id           :integer       not null, primary key
#  volunteer_id :integer       not null
#  friend_id    :integer       not null
#  frequency    :integer
#

class VolunteerFriend < ActiveRecord::Base
  belongs_to :volunteer

  def self.friend_exists(friend_id, volunteer_id)
    @volunteer_friend = VolunteerFriend.find(:all,
      :conditions => [ "volunteer_id = ? AND friend_id = ?",
        volunteer_id, friend_id]
    )
    if !@volunteer_friend.blank?
      true
    else
      false
    end
  end

end
