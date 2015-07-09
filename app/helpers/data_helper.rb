module DataHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  def get_session_survey
    session[:survey] ||= Survey.new
  end

  def error_messages_for_step(step)
    survey = instance_variable_get('@survey')
    survey_errors = survey.errors_step(step)

    header = "#{pluralize(survey_errors.length,"error")} prohibited completion of this step"

    errors = ""
    survey_errors.each do |msg|
      errors += content_tag(:li,msg)
    end
    content = content_tag(:div,content_tag(:h2,header) + content_tag(:ul,errors),:id=>"errorExplanation",:class=>"errorExplanation")
    content
  end

def error_messages_for_survey
    survey = instance_variable_get('@survey')
    survey_errors = survey.all_errors

    header = "#{pluralize(survey_errors.length,"error")} prohibited saving of this survey"

    errors = ""
    survey_errors.each do |msg|
      errors += content_tag(:li,msg)
    end
    content = content_tag(:div,content_tag(:h2,header) + content_tag(:ul,errors),:id=>"errorExplanation",:class=>"errorExplanation")
    content
  end

  def guess_step(survey = nil)
    if not params[:s].nil? and params[:s] =~ /^[1-5]$/
      params[:s].to_i
    elsif not survey.nil? and survey.step <= Survey::STEP_COMPLETE
      survey.step
    else
      0
    end
  end

  # CSS tags to be used by _step.rhtml
  def step_tags(current_step,completed_steps)
    tags = {}
    for i in 1 .. Survey::STEP_COMPLETE
      tags[i] = []
    end

    tags[4] << "mainNavNoBg"

    last_done_step = 0
    tags[current_step].push("current")
    if completed_steps > current_step
      tags[current_step].push("nextDone")
    end
    if current_step > 1
      tags[current_step - 1] << ("lastDone")
      last_done_step = current_step - 1
    end

    if completed_steps > 1
      for i in 1 .. completed_steps
        if i != current_step and i != last_done_step 
          tags[i] << "done"
        end
      end
    end
    tags.each {|k,v| tags[k] = v.join(" ")}
    return tags
  end

  def step_urls(completed_steps)
    urls = {}
    n = 1 .. Survey::STEP_COMPLETE
    n.each { |t|
      if t <= completed_steps
        urls[t] = %Q|href="/data/enter_data?s=#{t}"|
      else
        urls[t] = %Q|title=""|
      end
    }
    urls
  end

  def step_page(step)
    steps = {
      1 => 'step_who',
      2 => 'step_when',
      3 => 'step_beach',
      4 => 'step_birds'
    }

    steps[step]
  end

  # options
  # :start_date, sets the time to measure against, defaults to now
  # :date_format, used with <tt>to_formatted_s<tt>, default to :default
  def timeago(time, options = {})
    start_date = options.delete(:start_date) || Time.new
    date_format = options.delete(:date_format) || :default
    delta_minutes = (start_date.to_i - time.to_i).floor / 60
    if delta_minutes.abs <= (8724*60) # eight weeks-- I’m lazy to count days for longer than that
      distance = distance_of_time_in_words(delta_minutes);
      if delta_minutes < 0
        "#{distance} from now"
      else
        "#{distance} ago"
      end
    else
      return "on #{system_date.to_formatted_s(date_format)}"
    end
  end

  def distance_of_time_in_words(minutes)
    case
      when minutes < 1
        "less than a minute"
      when minutes < 50
        pluralize(minutes, "minute")
      when minutes < 90
        "about one hour"
      when minutes < 1080
        "#{(minutes / 60).round} hours"
      when minutes < 1440
        "one day"
      when minutes < 2880
        "about one day"
      else
        "#{(minutes / 1440).round} days"
    end
  end

end
