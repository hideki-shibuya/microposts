class User < ActiveRecord::Base
    before_save { self.email = self.email.downcase }
    validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 150 }, allow_blank: true
    validates :name, presence: true, length: { maximum: 50 }
    validates :profile, length: { maximum: 200 }, allow_blank: true
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    has_secure_password
    validates :password, presence: true, length: {minimum: 6 }, allow_nil: true
    has_many :microposts, dependent: :destroy
    
    has_many :following_relationships, class_name: "Relationship",
                                       foreign_key: "follower_id",
                                       dependent: :destroy
    has_many :following_users, through: :following_relationships, source: :followed
    
    has_many :follower_relationships, class_name:  "Relationship",
                                      foreign_key: "followed_id",
                                      dependent: :destroy
    has_many :follower_users, through: :follower_relationships, source: :follower
    
    def feed_items
        Micropost.where(user_id: following_user_ids + [self.id])
    end
    
    # 他のユーザーをフォローする
    def follow(other_user)
        following_relationships.find_or_create_by(followed_id: other_user.id)
    end
    
    # フォローしているユーザーをアンフォローする
    def unfollow(other_user)
        following_relationship = following_relationships.find_by(followed_id: other_user.id)
        following_relationship.destroy if following_relationship
    end
    
    # あるユーザーをフォローしているかどうか？
    def following?(other_user)
        following_users.include?(other_user)
    end
end
