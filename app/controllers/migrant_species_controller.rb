class MigrantSpeciesController < ApplicationController

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :migrant_species do |config|
    config.columns = [:species, :migrant_region, :status]

    config.columns[:species].form_ui = :select
    config.columns[:migrant_region].form_ui = :select
  end

end
