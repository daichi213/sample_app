require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    # assert_no_differenceは引数のUsers.countの値がブロック内の実行の前後で変化が無い場合にGREENを出力
    assert_no_difference "User.count" do
      post signup_path, params:{user: {name: "",
                          email: "user@invalid",
                          password: "foo",
                          password_confirmation: "foo"}
      }
    end
    # /users/newのページが再描画されるかのテスト
    # gemファイルにrails-controller-testingを追加するように指示、追加後エラー解消
    assert_template 'users/new'
    # 細かくチェックする場合はブロックを利用してその子要素のテストを行う。
    assert_select "div#error_explanation"
    assert_select "div.alert-danger"
    # formタグ以下に、action="/signup"タグがあれば成功
    # assert_select 'form[action="/signup"]'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count',1 do
      post signup_path, params: {user: {name:"Example User",
                          email:"user@example.com",
                          password:"password",
                          password_confirmation:"password"}}
    end
    # 送信結果を確認して、指定されたリダイレクト先に移動するメソッド
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
end
