class CaseCallback
  # Modify case of input parameter, defaulting to title case:
  #   'title case words' becomes 'Title Case Words'
  # pass a :method parameter for alternate methods

  # call with attributes needing Title Case
  def initialize(parameters)
    #@o = { :method => 'titlecase' }.merge(options)
    @parameters = parameters
  end

  def before_validation(model)
    @parameters.each do |key, value|
      puts model[key]
    end
    #case_string = "'#{model[@parameter]}'.#{@o[:method]}"
    #model[@parameter] = eval(case_string)
   end
end
