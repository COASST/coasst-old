class SubgroupController < ApplicationController

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :subgroup do |config|
    config.columns = [:name, :group]

    # attributes used in create & update
    base_columns = [:name, :group]

    # list options
    config.list.per_page = 25
    config.list.sorting = { :name => :asc}

    # creation options
    create.link.label = "Add new subgroup"
    create.columns = base_columns

    # update options
    update.columns = base_columns

    config.columns[:group].form_ui = :select
  end

end
