class SessionCleaner
  def self.remove_stale_sessions
    ActiveRecord::SessionStore::Session.
      destroy_all( ['updated_at <?', 1.weeks.ago] ) 
  end
end
