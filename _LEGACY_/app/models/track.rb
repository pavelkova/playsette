class Track < ApplicationRecord
  ### DISPLAY SCOPES
  default_scope -> { order(created_at: :desc) } # on user profile
  # (scope for ordering by likes) # on index - top
  scope :popularity, -> { order(likes: :desc) }
  # scope :audio, posted.where(playback: 'audio')
  # scope :video, posted.where(playback: 'video')

  ####################
  # SETUP: PROPERTIES,
  # RELATIONSHIPS
  ####################
  # Tracks belong to a user and will be deleted if the account is deactivated.
  belongs_to :user
  # Set up
  belongs_to :media, polymorphic: true, dependent: :destroy

  # Album art managed by Paperclip; URL fetching with open-uri
  has_attached_file :album_art,
                    styles: { icon: { geometry: '300x300>' },
                              large: { geometry: '800x800>',
                                       convert_options: '-colorspace Gray' } },
                    content_type: { content_type: %r{/\Aimage\/.*\z/} },
                    size: { in: 0..1000.kilobytes }

  ####################
  # INITIALIZE TRACK:
  # USER, SOURCE, MEDIA
  ####################
  validates :user_id, presence: true
  validates :playback, inclusion: { in: %w[audio video preview] }
  validates :media_path, presence: true

  ####################
  # AFTER MEDIA SOURCE:
  # METADATA AND ARTWORK
  ####################
  # Metadata
  validates :title, length: { maximum: 255 }, presence: true, on: :update
  validates :album, length: { maximum: 255 }, allow_blank: true, on: :update
  validates :artist, length: { maximum: 255 }, presence: true, on: :update
  validates :year, length: { is: 4 }, allow_blank: true, on: :update
  validates_attachment :album_art,
                       content_type: { content_type: ['image/jpeg',
                                                      'image/gif',
                                                      'image/png'] }

  ####################
  # FINALIZE SUBMISSION
  # AND CLEANUP
  ####################
  def destroy_if_left_unpublished
    TracksCleanupJob.set(wait: 1.hour).perform_later(self)
  end

  def player_build_error
  end

  def missing_metadata_error
  end

  ##############################
  # RELOAD EXPIRED BANDCAMP LINKS
  # WHEN THEY ARE VIEWED
  ###############################
  after_find :check_bandcamp, only: [:show, :index]

  def check_bandcamp
    if (self.media_type == 'Embedded') && (Embedded.find(self.media_id).source_service == 'Bandcamp')
      begin
        Nokogiri::HTML(open(self.media_path)) do
          return
        end
      rescue OpenURI::HTTPError => e
        embed = Embedded.find(self.media_id)
        new_call = BandcampService.new(url: embed.source_path).base_call
        new_media = new_call[:tracks][0][:file].values.last
        self.media_path = new_media
        self.save!
      end
    end
  end

  ####################
  # SOCIAL ATTRIBUTES:
  # LIKES AND COMMENTS
  ####################
  has_many :likes, as: :likeable
  # Display (on user profile, main index)
end