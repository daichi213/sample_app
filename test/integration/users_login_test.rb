require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'session/new'
    # paramsもハッシュのキーとして記述しなければならない
    # paramsをキーに持つハッシュを調べれば理解深まる？class,superclassメソッドを利用して
    post login_path, params: {session: {email:"",
                                      password:""}}
    assert_template 'session/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information" do
    get login_path
    post login_path, params: {session: {email: @user.email,
                                      password:'password'}}
    # assert_templateのリダイレクト版でredirect先が正しいかを検証している
    # 因みにredirectedと完了形になっているので注意する
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    # login先が存在しないかどうかを検証している
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

  test "login with valid information followed by logout" do
    # ログアウトのテストを行うために一度ログインする必要があるため、一度login_pathにアクセスしている
    # ページへのアクセスをシミュレートするにはhttpメソッドにroutingを対応させて記述する
    get login_path
    post login_path, params: {session: {email: @user.email,
                                      password:'password'}}
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_path
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user)
    # assert_not_empty cookies['remember_token']
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  # cookieがログアウト時に正常に削除されるどうかも併せてテスト
  test "login without remembering" do
    # cookieを保存してログイン
    log_in_as @user
    delete logout_path
    # cookieを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
