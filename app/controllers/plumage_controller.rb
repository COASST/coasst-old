class PlumageController < ApplicationController

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :plumage do |config|
    config.columns = [:name, :code, :admin_only]

    # attributes used in create & update
    base_columns = [:name, :code, :admin_only]

    # list options
    config.list.per_page = 25
    config.list.sorting = { :name => :asc}

    # creation options
    create.link.label = "Add new plumage"
    create.columns = base_columns

    # update options
    update.columns = base_columns
  end

end
