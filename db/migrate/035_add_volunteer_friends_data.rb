class AddVolunteerFriendsData < ActiveRecord::Migration
  extend DataLoader

  def self.up
    load_data "volunteer_friends"
  end

  def self.down
    execute("DELETE FROM volunteer_friends WHERE id IS NOT NULL")
  end
end
