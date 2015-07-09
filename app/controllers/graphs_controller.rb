require 'rubygems'
require 'sparklines'

class GraphsController < ApplicationController

  def default_sparkline_options
    {
      :background_color => 'transparent', #"#dedad1",
      :step             => 3,
      :height           => 20,
      :line_color       => "#6699cc",
      :underneath_color => "#ebf3f6",
      :target_color     => "#c2c2c2",
    }
  end

  def show
    data = [1,3,4,5,2,4,-1]
    graph   = Sparklines.plot_to_image [1,3,4,5,2,4,-1], default_sparkline_options
    #annotate(graph, "Daily Dynamic Hits")
    graph = graph.to_blob
    send_data graph, :type => "image/png", :disposition => "inline"
  end

  def species
    species = Species.find(params[:id])
    if species.birds.count == 0
      graph = Magick::Image.read("#{RAILS_ROOT}/public/images/no-birds-graph.png").first
    else
      graph = Sparklines.plot_to_image species.get_graph_data, default_sparkline_options.merge({
        :step   => 3,
        :height => 25,
        :has_max => true,
        #:type    => 'discrete'
      })
    end
    graph = graph.to_blob
    send_data graph, :type => "image/png", :disposition => "inline"
  end

  def annotate(graph, text)
  end

end
