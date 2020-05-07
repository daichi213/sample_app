class User < ApplicationRecord
    # ependent: :destroyはオプションでuserのレコードを削除すると関連付けられているmicropostsのレコードも削除される
    has_many :microposts, dependent: :destroy
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

    def feed
        Micropost.where("user_id = ?", id)
    end
end
