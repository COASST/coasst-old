class SpeciesPlumagesController < ApplicationController

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :species_plumage do |config|
    config.actions.exclude :delete, :remove
    config.columns = [:species, :plumage, :admin_only]

    config.columns[:species].form_ui = :select
    config.columns[:plumage].form_ui = :select
    config.columns[:admin_only].form_ui = :checkbox
  end

end
