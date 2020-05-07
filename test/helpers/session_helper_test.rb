require 'test_helper'

class SessionHelperTest < ActionView::TestCase

    # 最初に下のsetupメソッドを実行することで記憶トークンとデジタル署名を行ったuser_idを保存する
    def setup
        @user = users(:michael)
        remember @user
    end

    # session_helperのcurrent_userメソッドのテスト
    # current_userの返却値がテストユーザーのものと同一かをテスト
    test "current_user returns right user when session is nil" do
        # session_helperに定義したcurrent_userメソッドを実行
        assert_equal @user, current_user
        assert is_logged_in?
    end

    # ユーザーの記憶トークンとサーバーに保存されているremember_digestの値が異なる場合に現在のユーザーがnilになるかをテスト
    test "current_user returns nil when remember digest is wrong" do
        # setupを実行した時点で@user.remember_tokenには作成時点でのトークンが格納されている
        # 下のコードで:remember_digestにもう一度新しいトークンを保存
        @user.update_attribute(:remember_digest, User.digest(User.new_token))
        assert_nil current_user
    end
end