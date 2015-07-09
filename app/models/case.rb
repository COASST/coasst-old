class Case
  # Modify case of input parameter, defaulting to title case:
  #   'title case words' becomes 'Title Case Words'
  # pass a :method parameter for alternate methods

  # call with attributes needing Title Case
  def initialize(parameter, options = {})
    @o = { :method => 'titlecase' }.merge(options)
    @parameter = parameter
    return eval("@parameter.#{@o[:method]}")
  end

end
