class User < ApplicationRecord
    # ependent: :destroyはオプションでuserのレコードを削除すると関連付けられているmicropostsのレコードも削除される
    # has_manyで関連付けるテーブル名は複数形になっていることに注意
    has_many :microposts, dependent: :destroy
    has_many :active_relationships, class_name: "Relationship",
                                    foreign_key: "follower_id",
                                    dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship",
                                    foreign_key: "followed_id",
                                    dependent: :destroy
    # sourceに指定するキーはカラム名（「名称」＿id）名称部のみを指定する
    has_many :following, through: :active_relationships, source: :followed
    # この:followersは＋_idで関連先のカラム名に対応するためsourceを指定しなくても自動的に参照してくれる
    has_many :followers, through: :passive_relationships, source: :follower
    attr_accessor :remember_token
    # あるオブジェクトがDBに保存される直前に実行される処理
    # ここでは、保存するデータを全てdowncaseメソッドで小文字に変換している
    before_save {self.email = email.downcase}   # または、{email.downcase!}
    validates(:name, presence: true , length: {maximum:50})
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates(:email, presence: true , length: {maximum:255}, 
                format: {with: VALID_EMAIL_REGEX}, 
                # {case_sensitive: false}をまるごとtrueに置き換えることで大文字と小文字を区別しなくなる
                uniqueness: {case_sensitive: false})

    has_secure_password
    # has_secure_passwordの存在性のバリデーションは新しくレコードが追加されたときだけ動作する
    validates :password, presence: true, length: {minimum: 6}, allow_nil: true

    def User.digest(string)
        # 以下はコストパラメーターをテスト中は最小にし、本番環境ではしっかりと計算する方法
        # min_costと?をくっつけるとメソッドと誤認識されるためしっかり離す
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                    BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    def User.new_token
        SecureRandom.urlsafe_base64
    end

    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    def authenticated?(remember_token)
        return false if remember_digest.nil?
        # ここのremember_tokenは当メソッドで引数に定義したローカル変数を示している
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end

    def forget
        update_attribute(:remember_digest, nil)
    end

    # current_userのHomeページにフォローしているユーザーの投稿を表示させるためのメソッド
    # このメソッドではfollowing_idsはDB内に保存される。RailsとDBが一度しかやり取りしないため、処理が効率的になる。
    def feed
        following_ids = "SELECT followed_id FROM relationships
                    WHERE follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids})
                    OR user_id = :user_id", user_id: id)
    end

    def follow(other_user)
        following << other_user
    end

    def unfollow(other_user)
        active_relationships.find_by(followed_id: other_user.id).destroy
    end

    def following?(other_user)
        following.include?(other_user)
    end
end
