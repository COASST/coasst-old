module ApplicationHelper

  # Permissions
  def volunteer_has_role(roles)
    volunteer = Volunteer.find_by_id(session[:volunteer_id])
    if volunteer.has_role?(roles)
      true
    else
      false
    end
  end

  # rudimentary to_words filter for numbers
  def number_to_word(number)
    lookup = {
      0 => 'zero',
      1 => 'one',
      2 => 'two',
      3 => 'three',
      4 => 'four',
      5 => 'five',
      6 => 'six',
      7 => 'seven',
      8 => 'eight',
      9 => 'nine'
    }
    if number.to_i > 10
      number.to_s
    else
      lookup[number.to_i]
    end
  end

  # Indicator for AJAX requests
  def indicator_span
    content_tag(:span, image_tag("icons/indicator_snake.gif"), 
      :style => "display: none;",
      :id => "activity_indicator")

  end

  # Nicely styled buttons
  ButtonInfo = {
    :submit   => {:icon => 'tick.png', :class => 'positive'},
    :cancel   => {:icon => 'cross.png', :class => 'negative'},
    :delete   => {:icon => 'delete.png', :class => 'delete label'},
    :clear    => {:icon => 'bin_empty.png', :class => 'neutral'},
    :add      => {:icon => 'add.png', :class =>'positive label'},
    :go_back  => {:icon => 'go_back.png', :class => 'neutral'},
    :positive => {:icon => 'tick.png', :class => 'positive'}
  }

  # button order list, must match ButtonInfo
  ButtonOrder = [
    :go_back,
    :submit,
    :cancel,
    :delete,
    :clear,
    :add,
    :positive,
  ]

  def button_body(name, text)
    icon = (ButtonInfo.has_key? name) ? ButtonInfo[name][:icon] : ButtonInfo[:submit][:icon]
    image_tag("icons/#{icon}") + text
  end

  def button_style(name)
    (ButtonInfo.has_key? name) ?  ButtonInfo[name][:class] : ButtonInfo[:submit][:class]
  end

  def button_href(href = {})
    case href
      when :back
        url = request.env["HTTP_REFERER"]
      when %r{^[0-9]$}
        url = self.url_for(:action => 'enter_data', :s => href)
      when href.is_a?(String)
        url = href  
      else
        url = self.url_for(href)
    end
    url
  end

  def button_elem(name, text, href = {}, more_options = {})
    options = {:class => button_style(name)}
    if more_options[:post] == true
      options[:method] = :post
    end
    link_to button_body(name,text), button_href(href), options
  end

  def button_submit(name, text)
    content_tag(:button, button_body(name, text),
                :type  => 'submit',
                :value => text,
                :name  => name,
                :class => button_style(name))
  end

  def button_div(attributes = {})

    if block_given?
      concat('<div class="buttons">')
      yield
      concat('</div>')
    else 
      content = ''
      ButtonOrder.each do |k|
        if attributes.has_key?(k)
          v = attributes[k]
          if k == :submit
            if v.is_a?(String)
              content += button_submit(k, v)
            else
              content += button_elem(k, v[:text], v[:url])
            end
          elsif ButtonInfo.has_key?(k)
            if v.is_a?(Hash) and v.has_key?(:text)
              text = v[:text]
            else
              text = k.to_s.humanize.titleize
            end
            if v.is_a?(Hash) and v.has_key?(:url)
              link = v[:url]
            else
              link = v
            end           
            if v.is_a?(Hash)
              content += button_elem(k,text,link,v)
            else
              content += button_elem(k,text,link)
            end
          end
        end
      end

      content_tag(:div, content, :class => 'buttons')
    end
  end

  # Display nicely formatted fields, depending on the data type of inputs
  def display_field_group (group_name, data, fields, link_classes = true)

    # may want to push these fields into the models as a field attributes
    date_fields = [ 'vehicles_start', 'vehicles_end', ]

    mapped_fields = {
      'orientation'   => Beach::Orientation,
      'width'         => Beach::Width,
      'geomorphology' => Beach::Geomorphology,
    }

    unit_fields = { 
      'length'        => 'km',
      'oil_frequency' => 'm',
    }

    image_fields = [
      'weather',
    ]

    html = ""
    for f in fields
      if (f.class == Symbol)
        val = data.send(f)
        case val
        when ActiveRecord::Base
          val_name = val.name? ? val.name.to_s : val.to_s
          if link_classes
            val = link_to val_name, :controller => val.class.to_s.downcase,
                    :action => "show", :id => val.id
          else
            val = val_name
          end
        when TrueClass, FalseClass
          val = val.to_bs
        else
          if date_fields.include? f.to_s and !val.blank?
            val = Date::ABBR_MONTHNAMES[val.to_i]
          elsif mapped_fields.include? f.to_s
            val = mapped_fields[f.to_s].to_h[val.to_s]
          elsif unit_fields.include? f.to_s
            if not val.blank?
              val = "#{val.to_s} #{units_abbr(unit_fields[f.to_s])}\n"
            end
          elsif image_fields.include? f.to_s
            val = "#{val.to_s} " + image_tag("icons/weather_#{val.to_s.downcase}.png")
          else
            val = h(val.to_s.gsub('<br>', '\n')).gsub!('\n', '<br />')
          end
        end
        key = f.to_s.humanize
      elsif (f.class == Array)
        key = f.first
        val = f.last
      end
      if not val.blank?
        html += "<b>" + key + ":</b> " + val + "<br />\n"
      end
    end
    if not html.empty?
      html = content_tag(:h3,group_name) + html
    end
    html
  end

  # Units dictionary to provide acronyms for rendered units 
  def units_abbr(unit_type = 'mm')
    @Unit = {
      'mm'  => 'millimeters',
      'cm'  => 'centimeters',
      'ft'  => 'feet',
      'km'  => 'kilometers',
      'm'   => 'meters',
      'min' => 'minutes',
    }
    if @Unit[unit_type]
      return "<acronym title=\"#{@Unit[unit_type]}\">#{unit_type}</acronym>"
    end
  end

  # ActiveScaffold elements
  def elem_select(element)
    if not element.blank?
      logger.info("element wasn't empty, #{element.id}")
      element.id
    else
      nil
    end
  end

  # Monkey patch so radio buttons get display inline instead of one radio button per line
  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    if html_tag =~ /<(input)[^>]+type=["'](hidden)/
      html_tag
    elsif html_tag =~ /<(input)[^>]+type=["'](radio|checkbox)/
      "<div class=\"fieldWithErrors\" style=\"display: inline;\">#{html_tag}</div>"
    else
      "<div class=\"fieldWithErrors\">#{html_tag}</div>"
    end
  end

  # Provide environment information when in development
  def debug_block
    if ENV['RAILS_ENV'] == 'development'
      debug_div = <<-EOT
      <div id="debug" style="margin: 80px 5px 5px 5px;">
        <a href="#" onclick="Element.toggle('debug_info');return false" style="text-decoration: none; color: #ccc;">Show Debug Info &#10162;</a>
        <div id="debug_info" style="display : none;">

        <b>Survey:</b>
        #{debug @survey}

        <b>Session:</b>
        #{debug session}

        <b>Params:</b>
        #{debug params}
      </div>
      </div>
      EOT
      return debug_div
    end
  end

end
