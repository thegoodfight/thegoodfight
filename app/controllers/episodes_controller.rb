class EpisodesController < ApplicationController
  before_filter :touch_session, only: :show

  def show
    @episode = if params[:id] =~ /^\d+$/
      Episode.find(params[:id])
    else
      Episode.where(slug: params[:id]).first or raise ActiveRecord::RecordNotFound
    end

    # TODO Refactor.
    if @episode.possible_player_types.length == 1
      if params[:player].present?
        redirect_to episode_path(id: @episode.slug, ref: params[:ref]) and return
      else # Just render.
        @player = @episode.possible_player_types[0]
      end
    else
      if params[:player].present?
        if !Episode::Players::POSSIBLE_TYPES.include?(params[:player])
          redirect_to episode_path(id: @episode.slug, ref: params[:ref]) and return
        else
          session[:player] = params[:player]
          @player = params[:player]
        end
      elsif session[:player].present?
        redirect_to typed_episodes_path(id: @episode.slug, player: session[:player], ref: params[:ref]) and return
      else
        redirect_to typed_episodes_path(id: @episode.slug, player: @episode.possible_player_types[ rand(2) ], ref: params[:ref]) and return
      end
    end

    @canonical_fb_url = if @episode.possible_player_types.length == 1
      episode_url(id: @episode.slug, ref: params[:ref] || "fb", protocol: "http")
    else
      typed_episodes_url(id: @episode.slug, player: @player, ref: params[:ref] || "fb", protocol: "http")
    end

    respond_to do |f|
      f.html { }
      f.json { render json: @episode.attributes.slice(
        "title", "state", "show_notes", "description", "headline"
        ).merge(
          "id" => @episode.slug,
          "permalink" => episode_url(@episode)
        ).to_json
      }
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
    email = Episode.where(slug: params[:id]).first.email
    # email = Email.where(episode_id: params[:id]).first.tap {|e| e.renderer = self }
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
