class StateController < ApplicationController

  layout 'plain'
  def show
    state_id = params[:id].to_i
    @state = State.find(state_id,:include=>[:beaches])
  end

end
