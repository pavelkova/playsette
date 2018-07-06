class User < ApplicationRecord
  has_many :tracks, dependent: :destroy
  has_many :likes, inverse_of: :user, dependent: :destroy
  has_many :comments, inverse_of: :user, dependent: :destroy

  has_many :active_follows, class_name: 'Follow',
                            foreign_key: 'follower_id',
                            dependent: :destroy
  has_many :passive_follows, class_name: 'Follow',
                             foreign_key: 'followed_id',
                             dependent: :destroy
  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  attr_accessor :remember_token, :activation_token, :reset_token
  before_create :create_activation_digest
  before_save { email ? :downcase_email : nil }

  # Name must be between 5 and 51 characters and can contain upper and lowercase
  # letters, spaces, periods (for initials), and hyphens
  # (for combined last names). Must begin and end with a letter.
  VALID_NAME_REGEX = /\A[a-zA-Z]+[a-zA-Z\s\.-]*[a-zA-Z]+\z/

  validates :name,
            length: { in: 5..51 },
            format: { with: VALID_NAME_REGEX }

  # Email according to standard rules; uppercase letters are allowed,
  # but are converted to lowercase before saving. Length check is separate test.
  VALID_EMAIL_REGEX = /\A[\w\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  # Username must be between 5 and 22 characters,
  # must contain at least one letter, and is restricted to
  # lowercase letters, digits, periods, and underscores.
  VALID_USERNAME_REGEX = /\A(?=.*[a-z])+(?!.*([.][.]))[a-z\d\_.]*[a-z\d\_]+\z/

  validates :username,
            presence: true,
            length: { in: 6..22 },
            format: { with: VALID_USERNAME_REGEX },
            uniqueness: { case_sensitive: false }

  # Password must be between 6 and 72 (implicit) characters,
  # must contain one uppercase letter, one lowercase letter,
  # one number, and is not restricted to a set of characters.
  VALID_PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+\z/

  has_secure_password

  validates :password,
            presence: true,
            length: { minimum: 6 },
            allow_nil: true
  # format: { with: VALID_PASSWORD_REGEX }

  validates :profile_bio,
            length: { maximum: 500 }

  has_attached_file :avatar,
                    styles: { icon: '150x150#', small: '300x300#' },
                    content_type: { content_type: %r{/\Aimage\/.*\z/} },
                    default_url: 'users/default-profile.png',
                    size: { in: 0..1000.kilobytes }

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Token for browser remembering
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Set browser to remember
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Clear remember
  def forget
    update_attribute(:remember_digest, nil)
  end

  # activation
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def destroy_if_left_inactivated
    UsersCleanupJob.set(wait: 1.week).perform_later(self)
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def like(post)
    liked_type = post.class
  end

  def likes?(likeable)
    likes.include?(likeable)
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end