class CreateVolunteerFriends < ActiveRecord::Migration
  def self.up
    create_table :volunteer_friends do |t|
      t.column :volunteer_id, :integer, :null => false
      t.column :friend_id,    :integer, :null => false, :references => :volunteers
      t.column :frequency,    :integer
    end
  end

  def self.down
    drop_table :volunteer_friends
  end
end
