class Address

  attr_reader :address, :city, :state, :zip

  def initialize (address, city, state_id, zip)
    @address = address
    @city = city
    @state = State.find(state_id)
    @zip = zip
  end

  def to_s
    "#{@address}\n #{@city}, #{@state.prefix} #{@zip}"
  end
end
