class RedirectsController < ApplicationController
  def index
    logger.info "No path given; redirecting to /"
    redirect_to root_path
  end

  def show
    redirect = Redirect.where(path: params[:id]).first

    if redirect.present?
      redirect.increment('hits').save
      Fsj.statsd.increment "redirects.#{params[:id]}"

      destination = redirect.destination_url
      destination += "?" + request.query_string unless request.query_string.blank?

      redirect_to destination, status: 307
    else
      logger.error "Couldn't find a redirect for #{params[:id]}"
      not_found
    end
  end
end
