class FootTypeFamilyController < ApplicationController

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :foot_type_family do |config|
    config.columns = [:name, :description, :active]

    # attributes used in create & update
    base_columns = [:name, :description, :active, :toe_type]

    # link configuration
    delete.link.confirm = "Delete foot type family?"
    show.link.page = true

    # list options
    config.list.label = "Foot Type Families"
    config.list.per_page = 25
    config.list.sorting = { :name => :asc}

    # creation options
    create.link.label = "Add new foot type family"
    create.columns = base_columns

    # update options
    update.columns = base_columns

    config.columns[:toe_type].form_ui = :select

    # Make name required
    columns[:name].required = true

  end

end
