require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    # h1タグの内側に入っているimg.gravatarが存在するかのチェック
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination', count:1
    @user.microposts.paginate(page: 1).each do |micropost|
      # assert_matchはassert_selectのように具体的に第一引数を指定する必要はない
      # responseはhtml本文をすべて返すメソッド
      # ここでは、投稿数と表示件数が一致しているかをテストしている
      assert_match micropost.content, response.body
    end
  end

  # 自分で書いたテスト
  test "user followers and following information" do
    log_in_as @user
    get root_path
    assert_select "a[href=?]", following_user_path(@user), text: "#{@user.following.count}\nfollowing"
    assert_select "a[href=?]", followed_user_path(@user), text: "#{@user.followed.count}\nfollowed"
    get user_path @user
    assert_select "a[href=?]", following_user_path(@user), text: "#{@user.following.count}\nfollowing"
    assert_select "a[href=?]", followed_user_path(@user), text: "#{@user.followed.count}\nfollowed"
  end
end
