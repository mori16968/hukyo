class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 12 }
  before_create :default_avatar

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :avatar
  has_many :posts, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_posts, through: :favorites, source: :post
  has_many :comments, dependent: :destroy
  has_many :active_relationships,
           class_name: "Relationship",
           foreign_key: "following_id",
           dependent: :destroy
  has_many :followings, through: :active_relationships, source: :follower
  has_many :passive_relationships,
           class_name: "Relationship",
           foreign_key: "follower_id",
           dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :following
  has_many :active_notifications,
           class_name: "Notification",
           foreign_key: "visitor_id",
           dependent: :destroy
  has_many :passive_notifications,
           class_name: "Notification",
           foreign_key: "visited_id",
           dependent: :destroy

  def follow(other_user)
    followings << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(follower_id: other_user.id).destroy
  end

  def following?(other_user)
    followings.include?(other_user)
  end

  def feed
    Post.where("user_id IN (:following_ids) OR user_id = :user_id",
               following_ids: following_ids, user_id: id)
    # 下記のチュートリアルの記述だとrubocopに引っかかるので保留
    # following_ids = "SELECT follower_id FROM relationships WHERE following_id = :user_id"
    # Post.where("user_id IN (?) OR user_id = ?", following_ids, id)
  end

  def default_avatar
    if !avatar.attached?
      avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'default.png')),
                    filename: 'default.png',
                    content_type: 'image/png')
    end
  end

  def create_notification_follow(current_user)
    temp = Notification.where([
      "visitor_id = ? and visited_id = ? and action = ? ",
      current_user.id, id, "follow",
    ])
    if temp.blank?
      notification = current_user.active_notifications.new(
        visited_id: id,
        action: "follow"
      )
      notification.save if notification.valid?
    end
  end
end
