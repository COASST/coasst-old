# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_data_entry_session',
  :secret      => 'f6e132014dc411780b1a27c6ddb54d92709b2b948312d615ac980f5994cf4296c119bf477ab68023bb96c50838082010fd4025e7a77c9e3786704bf0278166b4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
