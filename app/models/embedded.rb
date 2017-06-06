require 'httparty'

class Embedded < ApplicationRecord
  include SessionsHelper
  has_one :track, as: :media, dependent: :destroy
  serialize :auto_metadata, Hash
  attr_accessor :tracks

  ####################
  # SETUP: SOURCES,
  # LINK CHECK
  ####################

  # Click-to-submit supplies source_path only.
  # First check for source_path,
  validates :source_path, presence: true
  # Then run custom validation against multiple valid url formats, and, if one is successfully matched, create an instance of the corresponding subclass.
  after_validation :get_source
  before_save :source_service, presence: true
  before_save :set_parameters
  before_save :player_url, presence: true
  before_save :auto_metadata, presence: true

  $VALID_BANDCAMP_FORMAT = /^[https?:\/\/]+([a-z]+)\.bandcamp\.com\/track\/([^#\&\?\/]*)/i
  $VALID_SOUNDCLOUD_FORMAT = /^(https?:\/\/)?(www.)?(m\.)?soundcloud\.com\/([\w\-\.]+)\/([\w\-\.]+)/i
  $VALID_SPOTIFY_FORMAT = /^[spotify:track:|https?:\/\/[a-z]+\.spotify\.com\/track\/]+([^#\&\?\/]*)/i
  $VALID_VIMEO_FORMAT = /^https?:\/\/vimeo\.com\/+([^#\&\?\/]*)/i
  $VALID_YOUTUBE_FORMAT = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/i

  ####################
  # BASE METHODS FOR
  # SOURCE SUBCLASSES
  ####################

  def get_source
    supported_sources = {
      $VALID_BANDCAMP_FORMAT => Bandcamp,
      $VALID_SOUNDCLOUD_FORMAT => Soundclouded, # Soundcloud gem uses "Soundcloud"
      $VALID_SPOTIFY_FORMAT => Spotify,
      $VALID_VIMEO_FORMAT => Vimeo,
      $VALID_YOUTUBE_FORMAT => Youtube
    }
    # Detect the urL_source by finding a match for source_path in the regex variables (keys in supported_sources)
    url_source = supported_sources.keys.detect { |valid_format| source_path.match(valid_format) }
    # source_service becomes instance of
    self.source_service = supported_sources.fetch(url_source)
    # playback type is audio by default (hidden form tag)
    # self.playback = 'video' if [Vimeo, Youtube].include?(self.source_service)
  end

  def set_parameters
    service = source_service.safe_constantize.new
    data = service.get_data(source_path)
    metadata = service.get_metadata(data)
    self.auto_metadata = metadata[0]
    self.player_url = metadata[1]
  end

  ####################
  # COMMON METHODS
  ####################

  # Simple call to external APIs
  def api_call(url)
    response = HTTParty.get(url)
    response.parsed_response
  end

  # Since the Embedded object is created before the Track object is validated,
  def submission_expired?
    created_at < 1.hour.ago
  end

end