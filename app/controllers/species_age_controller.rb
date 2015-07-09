class SpeciesAgeController < ApplicationController

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :species_age do |config|
    config.actions.exclude :delete, :remove

    config.list.per_page = 50
    config.list.sorting = {:species => :asc}

    config.columns = [:species, :age, :admin_only]

    config.columns[:species].form_ui = :select
    config.columns[:age].form_ui = :select
    config.columns[:admin_only].form_ui = :checkbox
  end

end
