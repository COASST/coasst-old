# SmartParse
class Time
  def parse_or_nil(string, comp = false)
    Time.parse(string, comp)
  rescue ArgumentError
    nil
  end

  def self.today
    Time.now.beginning_of_day
  end

  # push a few monkey patches for Chronic into this wrapper 
  def smart_parse(string, default = nil, comp = false, type = 'time')
    # four digit sequences should be interpeted as hh:ss times
    if string =~ /^\d\d\d\d$/
      string.insert(2,":")
    end

    # ignore leading zeroes in times like '01:00 pm', chronic can't hack it
    if string[0,1] == "0"
      string = string.slice(1, string.length)
    end

    # convert "0:00" into midnight for Chronic
    if string == '0:00' or string == '0'
      string = '24:00'
    end

    # remove everything extraneous from the input
		if type == 'time'
    	time_regex = Regexp.new(/([0-9:apm ]+)/ix)
    	match = time_regex.match(string)
    	if not match.nil?
      	string = match[1]
    	end
		end

    default ||= Time.today
    #logger.info("smart_parse: got: string #{string}, default #{default.class}, comp #{comp}")
    return default if string.blank?
    time = Chronic.parse(string, :context => :past) ||
           Chronic.parse(string.gsub(",", " "), :context => :past) ||
           default.parse_or_nil(string, comp) ||
           default
    return default if time.blank?
    #logger.info("smart_parse: got a 'smart' time of #{time.to_s}, for string #{string}")
    time
  end

  def logger
    ActionController::Base::logger
  end
end
 
