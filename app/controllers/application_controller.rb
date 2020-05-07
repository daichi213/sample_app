class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include UsersHelper
  # 自分で書いたhelperを読み込んでいるだけ
  include SessionHelper

  private

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
