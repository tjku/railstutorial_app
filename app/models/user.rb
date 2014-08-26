class User < ActiveRecord::Base

  before_create :create_remember_token
  before_save { self.email.downcase! }


  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id",
                           dependent: :destroy
  has_many :followed_users, through: :relationships,
                            source: :followed # necessary, because `followed_users` and `followed` are incompatible
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name: "Relationship", # necessary, because by default Rails will be searching for `ReverseRelationship` table
				   dependent: :destroy
  has_many :followers, through: :reverse_relationships,
                       source: :follower # in this case `source` can be ommited (`followers` search for `follower` by default)

  has_secure_password


  validates :name, presence: true,
                   length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 6 }


  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    self.relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    self.relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    self.relationships.find_by(followed_id: other_user.id).destroy
  end

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end

end

