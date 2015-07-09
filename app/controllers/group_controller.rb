class GroupController < ApplicationController

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :group do |config|
    config.columns = [:name, :code, :foot_type_family]

    # attributes used in create & update
    base_columns = [:name, :code, :foot_type_family, :active, :description, :composite]

    # list options
    config.list.per_page = 25
    config.list.sorting = { :name => :asc}

    # creation options
    create.link.label = "Add new group"
    create.columns = base_columns

    # update options
    update.columns = base_columns

    config.columns[:foot_type_family].form_ui = :select
  end

end
