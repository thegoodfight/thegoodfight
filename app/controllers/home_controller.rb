class HomeController < ApplicationController

  def index
    @episodes = Episode.order("recorded_at DESC").limit(11).all
    @latest = @episodes.shift

    @posts = Post.order(:created_at).limit(10).all

    @content = ( @posts + @episodes ).sort_by do |o|
      o.is_a?(Episode) ? o.recorded_at : o.created_at
    end
  end

end
