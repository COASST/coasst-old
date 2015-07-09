# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.18' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'google_analytics', :lib => 'rubaidh/google_analytics', :source => 'http://gems.github.com' 
  config.gem 'will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com' 
  config.gem 'mojombo-chronic', :lib => 'chronic', :source => 'http://gems.github.com' 

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  #config.time_zone = 'UTC'

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # See Rails::Configuration for more options
  config.plugins = [:all]

  # include the newrelic rpm as per instructions
  # http://support.newrelic.com/faqs/docs/ruby-agent-installation
  config.gem "newrelic_rpm"

  # force plugin reloading in development mode
  #config.reload_plugins = true if RAILS_ENV == 'development'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
ENV['FIXTURES'] ||= %w(roles rights rights_roles states counties 
                       migrant_regions regions beaches toe_types plumages 
                       foot_type_families groups subgroups species 
                       migrant_species species_plumages ages species_ages 
                       surveys birds volunteers 
                       survey_volunteers survey_tracks 
                       ).join(',')

# Custom date formatting
date_formats = {
  :survey      => "%A, %m/%d/%y",
  :concise     => "%d.%b.%y"
}

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(date_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(date_formats)

# Google Analytics tracking code, enabled only in production by default
Rubaidh::GoogleAnalytics.tracker_id = 'UA-8129183-1'

# Application-wide required plugins
require 'chronic' # natural language time parsing
require 'time'
require 'will_paginate'
