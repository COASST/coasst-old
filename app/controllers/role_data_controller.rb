class RoleDataController < ApplicationController

  layout 'admin'

  before_filter :check_authentication, :except => [:show]

  active_scaffold :role do |config|

    actions.exclude :search
    actions.add :live_search

    columns[:rights].form_ui = :select

  end

end
