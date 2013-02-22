module ApplicationHelper
  def page_link_to(title, opts={})
    path = Page.where(title: title).first.try(:slug)
    link_to title, path || "#", opts
  end

  def twitter_follow(account="fsjradio")
    raw <<-HTML
      <a href="https://twitter.com/#{account}" class="twitter-follow-button" data-show-count="false" data-size="small" data-show-screen-name="false">Follow @#{account}</a>
      <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
    HTML
  end

  def twitter_share(account="fsjradio")
    raw <<-HTML
      <a href="https://twitter.com/share" class="twitter-share-button" data-via="#{account}">Tweet</a>
      <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
    HTML
  end

  def facebook_follow(account="flamingswordofjustice")
    raw <<-HTML
      <div class="fb-follow" data-href="https://www.facebook.com/#{account}" data-show-faces="false" data-layout="button_count"></div>
    HTML
  end

  def facebook_like
    raw <<-HTML
      <div class="fb-like" data-send="true" data-width="120" data-layout="button_count" data-show-faces="false"></div>
    HTML
  end

  def livefyre_comments
    raw <<-HTML
    <div id="livefyre-comments"></div>
      <script type="text/javascript" src="http://zor.livefyre.com/wjs/v3.0/javascripts/livefyre.js"></script>
      <script type="text/javascript">
      (function () {
          var articleId = fyre.conv.load.makeArticleId(null);
          fyre.conv.load({}, [{
              el: 'livefyre-comments',
              network: "livefyre.com",
              siteId: "#{ENV['LIVEFYRE_SITE_ID']}",
              articleId: articleId,
              signed: false,
              collectionMeta: {
                  articleId: articleId,
                  url: fyre.conv.load.makeCollectionUrl(),
              }
          }], function() {});
      }());
      </script>
    HTML
  end

  def facebook_script
    raw <<-HTML
      <div id="fb-root"></div>
      <script>(function(d, s, id) {
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) return;
        js = d.createElement(s); js.id = id;
        js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=#{facebook_app_id}";
        fjs.parentNode.insertBefore(js, fjs);
      }(document, 'script', 'facebook-jssdk'));</script>
    HTML
  end

  def itunes_link
    ENV['ITUNES_URI']
  end

  def social_icons_for(model)
    render partial: 'shared/social_icons', locals: { model: model }
  end

  def open_graph_tags(attrs={})
    attrs[:image] ||= image_path("sword.png")
    attrs[:type]  ||= "website"
    attrs[:url]   ||= request.original_url
    attrs[:admin] ||= facebook_admin_id

    content_for :head do
      render partial: 'shared/open_graph', locals: attrs
    end
  end

  def facebook_admin_id
    ENV['FACEBOOK_ADMIN_ID']
  end

  def facebook_app_id
    ENV['FACEBOOK_APP_ID']
  end

  def share_this(model)
    render partial: 'shared/share_this', object: model, locals: { type: model.class.model_name }
  end
end
