require 'soundcloud'

class Embedded::Soundclouded

  def get_data(url)
    # Acceptable url example
    # https://soundcloud.com/theacid/the-acid-tumbling-lights
    # "http://api.soundcloud.com/resolve?url=https://soundcloud.com/beachseason/if-i-intro-1&client_id=#{Rails.application.secrets.soundcloud_client_id}"
    client = Soundcloud.new({
      :client_id => Rails.application.secrets.soundcloud_client_id,
      :client_secret => Rails.application.secrets.soundcloud_client_secret })

      data = {}

      begin
        data = client.get('/resolve', :url => url)
      rescue Soundcloud::ResponseError => e
        puts e
        puts "Error: #{e.message}, Status Code: #{e.response.code}"
      end

      begin
        embed_data = client.get('/oembed', :url => url)
      rescue Soundcloud::ResponseError => e
        puts "Error: #{e.message}, Status Code: #{e.response.code}"
      end

      # Soundcloud API throws 403 errors for resolve calls on certain urls.  If the url is valid, an oembed call should still work, and some metadata can be extracted
      data.artist ||= embed_data.author_name
      # embed_data.title will return "title by artist", cut to just title
      data.title ||= embed_data.title.split(' by ' + embed_data.author_name.to_s).first
      # Get id from url inside iframe
      data.id ||= embed_data.html[/tracks%2F(.*?)&show_artwork/, 1]
      # Always get artwork from embed_data
      data.artwork_url = embed_data.thumbnail_url
      puts data
      # Return data object
      data
  end

  def get_metadata(data)
    @track_id = data.id
    values = [{
    'text_data' => {
      :title => data.title,
      :artist => data.user['username'],
      :album => data.release,
      :year => self.year_from_date(data.release_year)
      },
      'album_art_url' => data.artwork_url
    },
    self.player_url]
    values
  end

  # Generate url with options for iframe
  def player_url
    "https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/#{@track_id}&amp;color=333333&amp;auto_play=false&amp;hide_related=true&amp;show_comments=false&amp;show_user=false&amp;show_reposts=false"
  end

  # Special method to check for album name in page since release is nil more often than not
  # def scrape(url)
  #   page = Nokogiri::HTML(open(url))
  #
  # end

  def year_from_date(date)
    if !date.nil?
      Date.strptime(date.to_s, '%Y').year
    else
      ''
    end
  end

  # Verify
  def matches_link?
  end

  # def is_track?
  #   data.kind == 'track' or embed_data.html.include? "%2Ftracks%2F"
  # end

end