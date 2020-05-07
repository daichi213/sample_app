module SessionHelper

    def log_in(user)
        session[:user_id] = user.id
    end

    def remember(user)
        user.remember
        # デジタル署名の暗号化技術によるセキュリティ
        cookies.permanent.signed[:user_id] = user.id
        # 記憶トークンを使用したセキュリティ
        # cookiesに保存されたidを確認することでユーザー本人を認識する
        cookies.permanent[:remember_token] = user.remember_token
    end

    def current_user?(user)
        user == current_user
    end

    def current_user
        # ifの条件式の意味はuser_idにsession[:user_id]の結果を代入してuser_idが存在すればtrueとなる
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: session[:user_id])
        elsif(user_id = cookies.signed[:user_id])
            # raise # テストされているかどうかを確認するための例外処理
            # 例外処理を記述した上でテストがパスした場合そこの処理をテストできていない
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    def logged_in?
        !current_user.nil?
    end

    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    def log_out
        # 以下のcurrent_userは上記current_userメソッドを示しており、このメソッドの返却値がここに代わる
        # ただし、railsのhelperに定義されるメソッドは返却値を明示的に示していないためメソッドの最下段付近に注目する
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end

    def redirect_back_or(default)
        # session[:forwarding_url]に値が入っている場合はこちらを優先的にリダイレクトさせる
        redirect_to(session[:forwarding_url] || default)
        session.delete(:forwarding_url)
    end

    def store_location
        # request.original_urlでリクエスト先のurlが取得できる
        session[:forwarding_url] = request.original_url if request.get?
    end
end
