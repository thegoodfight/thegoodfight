class EpisodesController < ApplicationController
  before_filter :touch_session, only: :show

  def show
    @episode = Episode.where(slug: params[:id]).first or raise ActiveRecord::RecordNotFound
    @player = @episode.has_video? && params[:type] == "v" ? "video" : "audio"

    ref = (params[:ref].present? && params[:ref] =~ /^\w+$/) ? params[:ref] : "none"
    Fsj.statsd.gauge "clicks.#{params[:id]}.#{ref}", "+1"

    respond_to do |f|
      f.html { }
      f.json { render json: @episode.to_json(only: [:title, :state, :show_notes, :description]) }
    end
  end

  def latest
    @episode = Episode.visible.first
    redirect_to episode_path(@episode)
  end

  def grouped
    @groups = Episode.grouped_by(params[:category])
    @category = params[:category]
  end

  def index
    @episodes = Episode.visible.all
  end

  def email
    email = EpisodeEmail.new(renderer: self, id: params[:id])
    render text: email.html, content_type: "text/html"
  end

  def audio
    @episode = Episode.find(params[:id])
    response.header['Content-Disposition'] = "attachment; filename=#{@episode.audio_filename}"

    if @episode.unpublished?
      render text: "Episode is unpublished - no audio stream available", status: :not_found
    elsif @episode.live?
      redirect_to ENV["LIVE_BROADCAST_URI"]
    else
      redirect_to @episode.download_url
    end
  end

end
