ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  #test環境でhelperを使用できるようにするための準備
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
    !session[:user_id].nil?
  end
  # テストユーザーとしてログインするためのメソッド
  # 予め引数に値をセットしておくことで、デフォルト設定とすることができる
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params:{session:{email: user.email,
                                      password: password,
                                      remember_me: remember_me}}
  end
end
